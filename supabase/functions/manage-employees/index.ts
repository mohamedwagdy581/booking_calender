/// <reference path="../send-push/globals.d.ts" />
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Admin-only employee management. Creating and disabling auth users needs the
// service-role key, so this must run on the server, never in the app.

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

const ROLES = ["admin", "staff"] as const;
type Role = typeof ROLES[number];
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
// ~100 years: Supabase has no permanent ban, this is the documented pattern.
const DISABLED_BAN = "876000h";

type AuthUser = {
  id: string;
  email?: string;
  created_at?: string;
  last_sign_in_at?: string | null;
  banned_until?: string | null;
  user_metadata?: Record<string, unknown>;
};

const isDisabled = (u: AuthUser) =>
  !!u.banned_until && new Date(u.banned_until).getTime() > Date.now();

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  try {
    // Built-in values injected by Supabase are always current; the custom
    // PROJECT_URL / SERVICE_ROLE_KEY secrets are only a fallback (a stale
    // SERVICE_ROLE_KEY secret made every admin query fail with 401).
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? Deno.env.get("PROJECT_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
      Deno.env.get("SERVICE_ROLE_KEY");
    if (!supabaseUrl || !anonKey || !serviceRoleKey) {
      console.error("manage-employees: missing env secrets");
      return json({ error: "server_not_configured" }, 500);
    }

    // 1. Caller must be a signed-in admin.
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) return json({ error: "unauthorized" }, 401);
    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    const caller = userData?.user;
    if (userError || !caller) return json({ error: "unauthorized" }, 401);

    const admin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });
    const { data: callerProfile } = await admin
      .from("profiles").select("role").eq("id", caller.id).maybeSingle();
    if (callerProfile?.role !== "admin") return json({ error: "forbidden" }, 403);

    const body = await req.json().catch(() => ({})) as Record<string, unknown>;
    const action = String(body.action ?? "");

    // 2. Actions
    if (action === "list") {
      const { data: profiles, error } = await admin
        .from("profiles").select("id, role");
      if (error) throw new Error(error.message);
      const roles = new Map(
        ((profiles ?? []) as { id: string; role: string | null }[])
          .map((p) => [p.id, p.role ?? "staff"]),
      );
      const users: AuthUser[] = [];
      for (let page = 1; page <= 20; page++) {
        const { data, error: listError } = await admin.auth.admin.listUsers({
          page,
          perPage: 200,
        });
        if (listError) throw new Error(listError.message);
        users.push(...(data.users as AuthUser[]));
        if (data.users.length < 200) break;
      }
      const employees = users
        .filter((u) => roles.has(u.id))
        .map((u) => ({
          id: u.id,
          email: u.email ?? "",
          full_name: String(u.user_metadata?.full_name ?? "").trim(),
          role: roles.get(u.id),
          disabled: isDisabled(u),
          created_at: u.created_at ?? null,
          last_sign_in_at: u.last_sign_in_at ?? null,
          is_self: u.id === caller.id,
        }))
        .sort((a, b) => String(a.created_at).localeCompare(String(b.created_at)));
      return json({ employees });
    }

    if (action === "create") {
      const email = String(body.email ?? "").trim().toLowerCase();
      const password = String(body.password ?? "");
      const fullName = String(body.full_name ?? "").trim().slice(0, 60);
      const role = String(body.role ?? "staff") as Role;
      if (!EMAIL_RE.test(email) || email.length > 254) {
        return json({ error: "invalid_email" }, 400);
      }
      if (password.length < 8 || password.length > 72) {
        return json({ error: "weak_password" }, 400);
      }
      if (!ROLES.includes(role)) return json({ error: "invalid_role" }, 400);

      const { data: created, error } = await admin.auth.admin.createUser({
        email,
        password,
        email_confirm: true,
        user_metadata: { full_name: fullName },
      });
      if (error || !created?.user) {
        const exists = /already|registered|exists/i.test(error?.message ?? "");
        return json({ error: exists ? "email_exists" : "create_failed" }, exists ? 409 : 400);
      }
      const id = created.user.id;

      // on_auth_user_created normally inserts the profile; set the role either way.
      const { data: updated, error: roleError } = await admin
        .from("profiles").update({ role }).eq("id", id).select("id");
      if (!roleError && (updated ?? []).length === 0) {
        await admin.from("profiles").insert({ id, email, role });
      }
      return json({ success: true, id });
    }

    const userId = String(body.user_id ?? "");
    if (!UUID_RE.test(userId)) return json({ error: "invalid_user" }, 400);
    // Prevents an admin from locking everyone out by demoting/disabling themselves.
    if (userId === caller.id) return json({ error: "cannot_change_self" }, 400);

    const { data: target } = await admin
      .from("profiles").select("id").eq("id", userId).maybeSingle();
    if (!target) return json({ error: "not_found" }, 404);

    if (action === "set_role") {
      const role = String(body.role ?? "") as Role;
      if (!ROLES.includes(role)) return json({ error: "invalid_role" }, 400);
      const { error } = await admin.from("profiles").update({ role }).eq("id", userId);
      if (error) throw new Error(error.message);
      return json({ success: true });
    }

    if (action === "set_disabled") {
      const disabled = body.disabled === true;
      const { error } = await admin.auth.admin.updateUserById(userId, {
        ban_duration: disabled ? DISABLED_BAN : "none",
      });
      if (error) throw new Error(error.message);
      if (disabled) {
        // Stop pushes to their devices immediately.
        await admin.from("device_tokens").delete().eq("user_id", userId);
      }
      return json({ success: true });
    }

    return json({ error: "unknown_action" }, 400);
  } catch (err: unknown) {
    console.error("manage-employees failed:", err instanceof Error ? err.message : err);
    return json({ error: "server_error" }, 500);
  }
});
