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

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("PROJECT_URL") ?? Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SERVICE_ROLE_KEY") ??
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const saRaw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");

    if (!supabaseUrl || !serviceRoleKey || !saRaw) {
      const missing: string[] = [];
      if (!supabaseUrl) missing.push("PROJECT_URL/SUPABASE_URL");
      if (!serviceRoleKey) missing.push("SERVICE_ROLE_KEY/SUPABASE_SERVICE_ROLE_KEY");
      if (!saRaw) missing.push("FCM_SERVICE_ACCOUNT_JSON");
      return new Response(
        JSON.stringify({
          error: "Missing required env secrets.",
          missing,
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const serviceAccount = JSON.parse(saRaw) as ServiceAccount;
    if (
      !serviceAccount.project_id || !serviceAccount.client_email ||
      !serviceAccount.private_key
    ) {
      return new Response(
        JSON.stringify({ error: "Invalid FCM service account JSON." }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const { title, body, data } = (await req.json()) as PushPayload;
    if (!title || !body) {
      return new Response(
        JSON.stringify({ error: "title and body are required." }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }
    const normalizedData = normalizeFcmData(data);

    const adminClient = createClient(supabaseUrl, serviceRoleKey);
    const { data: tokenRows, error: tokenError } = await adminClient
      .from("device_tokens")
      .select("token");

    if (tokenError) {
      return new Response(
        JSON.stringify({ error: tokenError.message }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const tokens = ((tokenRows ?? []) as TokenRow[])
      .map((r) => r.token ?? "")
      .filter((t) => !!t);

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({ success: true, sent: 0, message: "No device tokens found." }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

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

    return new Response(
      JSON.stringify({
        success: true,
        sent,
        total_tokens: tokens.length,
        removed_invalid_tokens: invalidTokens.length,
      }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err: unknown) {
    return new Response(
      JSON.stringify({ error: toErrorMessage(err) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
