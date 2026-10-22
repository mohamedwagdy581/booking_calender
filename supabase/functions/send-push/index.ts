/// <reference path="./globals.d.ts" />
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

type PushPayload = {
  title: string;
  body: string;
  data?: Record<string, unknown>;
};

type TokenRow = {
  token: string | null;
};

const textEncoder = new TextEncoder();

function base64Url(input: Uint8Array): string {
  const b64 = btoa(String.fromCharCode(...input));
  return b64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToArrayBuffer(pem: string): ArrayBuffer {
  const cleaned = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s+/g, "");
  const binary = atob(cleaned);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes.buffer;
}

async function getGoogleAccessToken(sa: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encodedHeader = base64Url(textEncoder.encode(JSON.stringify(header)));
  const encodedPayload = base64Url(textEncoder.encode(JSON.stringify(payload)));
  const unsignedJwt = `${encodedHeader}.${encodedPayload}`;

  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    pemToArrayBuffer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signatureBuffer = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    textEncoder.encode(unsignedJwt),
  );

  const jwt = `${unsignedJwt}.${base64Url(new Uint8Array(signatureBuffer))}`;

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const tokenJson = await tokenRes.json();
  if (!tokenRes.ok || !tokenJson.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenJson)}`);
  }
  return tokenJson.access_token as string;
}

function toErrorMessage(err: unknown): string {
  if (err instanceof Error) return err.message;
  return String(err);
}

function normalizeFcmData(data: Record<string, unknown> | undefined): Record<string, string> {
  if (!data) return {};
  const normalized: Record<string, string> = {};
  for (const [key, value] of Object.entries(data)) {
    if (value === null || value === undefined) continue;
    normalized[key] = String(value);
  }
  return normalized;
}

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

type PushType = "insert" | "update" | "archive" | "restore";
const PUSH_TYPES: readonly PushType[] = ["insert", "update", "archive", "restore"];
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function clip(value: unknown, max = 100): string {
  return String(value ?? "").trim().slice(0, max);
}

// The message is derived here from the stored booking; callers only say what happened.
function buildMessage(type: PushType, booking: Record<string, unknown>): PushPayload {
  const client = clip(booking.client_name);
  const artist = clip(booking.artist_name);
  const date = clip(booking.date, 10);
  const titles: Record<PushType, string> = {
    insert: "حجز جديد",
    update: "تم تحديث حجز",
    archive: "تمت أرشفة حجز",
    restore: "تم استرجاع حجز",
  };
  const bodies: Record<PushType, string> = {
    insert: `تم إضافة حجز جديد لـ ${client} مع ${artist} بتاريخ ${date}`,
    update: `تم تحديث بيانات حجز ${client} مع ${artist} بتاريخ ${date}`,
    archive: `تمت أرشفة حجز ${client} مع ${artist} بتاريخ ${date}`,
    restore: `تم استرجاع حجز ${client} مع ${artist} بتاريخ ${date}`,
  };
  return { title: titles[type], body: bodies[type] };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") return json({ error: "Method not allowed." }, 405);

  try {
    // Built-in values injected by Supabase are always current; the custom
    // PROJECT_URL / SERVICE_ROLE_KEY secrets are only a fallback (a stale
    // SERVICE_ROLE_KEY secret made every admin query fail with 401).
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? Deno.env.get("PROJECT_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
      Deno.env.get("SERVICE_ROLE_KEY");
    const saRaw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");

    if (!supabaseUrl || !anonKey || !serviceRoleKey || !saRaw) {
      console.error("send-push: missing required env secrets");
      return json({ error: "Server is not configured." }, 500);
    }

    // 1. Caller must be a signed-in employee.
    const authHeader = req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) return json({ error: "Unauthorized." }, 401);

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    const user = userData?.user;
    if (userError || !user) return json({ error: "Unauthorized." }, 401);

    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: { persistSession: false },
    });
    const { data: callerProfile } = await adminClient
      .from("profiles")
      .select("id")
      .eq("id", user.id)
      .maybeSingle();
    if (!callerProfile) return json({ error: "Forbidden." }, 403);

    // 2. Validate input: only the event type and booking id are accepted.
    const payload = await req.json().catch(() => null) as
      | { type?: unknown; booking_id?: unknown }
      | null;
    const type = payload?.type as PushType;
    const bookingId = String(payload?.booking_id ?? "");
    if (!PUSH_TYPES.includes(type) || !UUID_RE.test(bookingId)) {
      return json({ error: "type and booking_id are required." }, 400);
    }

    // 3. Read the booking as the caller, so RLS decides whether they may see it.
    const { data: booking, error: bookingError } = await userClient
      .from("bookings")
      .select("id, client_name, artist_name, date")
      .eq("id", bookingId)
      .maybeSingle();
    if (bookingError || !booking) return json({ error: "Booking not found." }, 404);

    const { title, body } = buildMessage(type, booking as Record<string, unknown>);
    const normalizedData = normalizeFcmData({ type, booking_id: bookingId });

    const serviceAccount = JSON.parse(saRaw) as ServiceAccount;
    if (
      !serviceAccount.project_id || !serviceAccount.client_email ||
      !serviceAccount.private_key
    ) {
      console.error("send-push: invalid FCM service account JSON");
      return json({ error: "Server is not configured." }, 500);
    }

    // 4. Recipients: devices owned by current employees only.
    const { data: employees, error: employeesError } = await adminClient
      .from("profiles")
      .select("id");
    if (employeesError) throw new Error(employeesError.message);
    const employeeIds = ((employees ?? []) as { id: string }[]).map((e) => e.id);
    if (employeeIds.length === 0) return json({ success: true, sent: 0 });

    const { data: tokenRows, error: tokenError } = await adminClient
      .from("device_tokens")
      .select("token")
      .in("user_id", employeeIds);
    if (tokenError) throw new Error(tokenError.message);

    const tokens = ((tokenRows ?? []) as TokenRow[])
      .map((r) => r.token ?? "")
      .filter((t) => !!t);

    if (tokens.length === 0) return json({ success: true, sent: 0 });

    const accessToken = await getGoogleAccessToken(serviceAccount);
    const fcmUrl =
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;

    let sent = 0;
    const invalidTokens: string[] = [];

    for (const token of tokens) {
      const response = await fetch(fcmUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body },
            data: normalizedData,
            android: { priority: "HIGH" },
            apns: {
              headers: { "apns-priority": "10" },
              payload: { aps: { sound: "default" } },
            },
          },
        }),
      });

      if (response.ok) {
        sent += 1;
      } else {
        const errJson = (await response.json().catch(() => ({}))) as Record<
          string,
          unknown
        >;
        const errText = JSON.stringify(errJson);
        if (errText.includes("UNREGISTERED") || errText.includes("INVALID_ARGUMENT")) {
          invalidTokens.push(token);
        }
      }
    }

    if (invalidTokens.length > 0) {
      await adminClient.from("device_tokens").delete().in("token", invalidTokens);
    }

    return json({ success: true, sent, total_tokens: tokens.length });
  } catch (err: unknown) {
    console.error("send-push failed:", toErrorMessage(err));
    return json({ error: "Push dispatch failed." }, 500);
  }
});
