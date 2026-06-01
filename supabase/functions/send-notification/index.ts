// supabase/functions/send-notification/index.ts
//
// FCM v1 — usa Service Account + OAuth2, no el legacy Server Key.
// El Service Account JSON debe estar en Supabase Vault como dos secrets:
//   FCM_CLIENT_EMAIL   → service_account.client_email
//   FCM_PRIVATE_KEY    → service_account.private_key  (el bloque RSA completo)
//   FCM_PROJECT_ID     → Firebase project ID (ej: "alma-diary-prod")
//
// Permisos requeridos en el Service Account:
//   roles/firebase.messagingSender  (o Firebase Cloud Messaging Admin)

import { createClient } from "jsr:@supabase/supabase-js@2";
import { encodeBase64Url } from "jsr:@std/encoding/base64url";

// -------------------------------
// CORS
// -------------------------------

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function ok(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

function err(message: string, status = 500, detail?: unknown): Response {
  const body: Record<string, unknown> = { error: message };
  if (detail !== undefined) body.detail = detail;
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

// -------------------------------
// OAUTH2 — Service Account → access token
// -------------------------------

/**
 * Genera un JWT firmado con la private key del Service Account
 * y lo intercambia por un OAuth2 Bearer token para FCM v1.
 *
 * El token tiene TTL de 1h — en una Edge Function stateless esto
 * se genera en cada invocación. Si el volumen es alto considera
 * cachear en Supabase KV o en una tabla con TTL.
 */
async function getFcmAccessToken(
  clientEmail: string,
  privateKeyPem: string
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  // 1. Construir JWT (header.payload)
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: clientEmail,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const encode = (obj: unknown) =>
    encodeBase64Url(new TextEncoder().encode(JSON.stringify(obj)));

  const headerB64 = encode(header);
  const payloadB64 = encode(payload);
  const signingInput = `${headerB64}.${payloadB64}`;

  // 2. Importar la clave RSA privada
  const pemBody = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");

  const keyBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  // 3. Firmar
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(signingInput)
  );

  const signatureB64 = encodeBase64Url(new Uint8Array(signature));
  const jwt = `${signingInput}.${signatureB64}`;

  // 4. Intercambiar JWT por access token
  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenRes.ok) {
    const body = await tokenRes.text();
    throw new Error(`OAuth2 token exchange failed (${tokenRes.status}): ${body}`);
  }

  const { access_token } = await tokenRes.json();
  return access_token as string;
}

// -------------------------------
// FCM v1 — envío individual
// -------------------------------

type FcmSendResult =
  | { token: string; status: "sent" }
  | { token: string; status: "invalid" }   // token a eliminar de la BD
  | { token: string; status: "error"; reason: string };

/**
 * Envía un mensaje a UN token vía FCM v1.
 * FCM v1 no soporta multicast — hay que iterar por token.
 */
async function sendToToken(
  token: string,
  title: string,
  body: string,
  projectId: string,
  accessToken: string
): Promise<FcmSendResult> {
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const res = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify({
    message: {
      token,
      notification: { title, body },
      android: {
        priority: "high",
        notification: {
          icon: "ic_notification",
          channel_id: "alma_channel",
        },
      },
      apns: {
        payload: { aps: { sound: "default" } },
      },
    },
  }),
  });

  if (res.ok) return { token, status: "sent" };

  const fcmErr = await res.json().catch(() => ({}));
  const fcmCode: string = fcmErr?.error?.status ?? "";

  // Tokens que FCM confirma como irrecuperables → limpiar de la BD
  if (
    fcmCode === "UNREGISTERED" ||
    fcmCode === "INVALID_ARGUMENT" ||
    res.status === 404
  ) {
    return { token, status: "invalid" };
  }

  return {
    token,
    status: "error",
    reason: fcmCode || `HTTP ${res.status}`,
  };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { status: 200, headers: CORS });
  }

  if (req.method !== "POST") {
    return err("Method not allowed", 405);
  }

  // - 1. Variables de entorno ----------------
  const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
  const FCM_CLIENT_EMAIL = Deno.env.get("FCM_CLIENT_EMAIL");
  const FCM_PRIVATE_KEY = Deno.env.get("FCM_PRIVATE_KEY");
  const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID");

  // Nuevo sistema de keys — SUPABASE_SECRET_KEYS es un JSON dict
  const secretKeysRaw = Deno.env.get("SUPABASE_SECRET_KEYS") ?? "{}";
  const secretKeys = JSON.parse(secretKeysRaw) as Record<string, string>;
  const serviceRoleKey = Object.values(secretKeys)[0] ?? "";

  if (!SUPABASE_URL || !serviceRoleKey || !FCM_CLIENT_EMAIL || !FCM_PRIVATE_KEY || !FCM_PROJECT_ID) {
    console.error("send-notification: missing env vars", {
      hasUrl: !!SUPABASE_URL,
      hasKey: !!serviceRoleKey,
      hasFcmEmail: !!FCM_CLIENT_EMAIL,
      hasFcmKey: !!FCM_PRIVATE_KEY,
      hasFcmProject: !!FCM_PROJECT_ID,
    });
    return err("Server misconfiguration", 500);
  }
// --- 2. Parsear body PRIMERO ---
let userId: string;
let title: string;
let body: string;

try {
  const parsed = await req.json();
  userId = parsed?.userId;
  title = parsed?.title;
  body = parsed?.body;
} catch {
  return err("Invalid JSON body", 400);
}

if (!userId || typeof userId !== "string" || userId.trim() === "") {
  return err("userId is required", 400);
}

 if (!title || typeof title !== "string") return err("title is required", 400);
  if (!body || typeof body !== "string") return err("body is required", 400);
// --- 2. Autenticar al caller ---
const authHeader = req.headers.get("Authorization") ?? "";
if (!authHeader.startsWith("Bearer ")) {
  return err("Unauthorized", 401);
}

const callerToken = authHeader.replace("Bearer ", "").trim();

// Aceptar secret key (llamadas internas/cron)
if (callerToken === serviceRoleKey) {
  // ok
} else {
  // Aceptar JWT de usuario autenticado (llamadas desde la app)
  const publishableKeysRaw = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS") ?? "{}";
  const publishableKeys = JSON.parse(publishableKeysRaw) as Record<string, string>;
  const anonKey = Object.values(publishableKeys)[0] ?? "";

  const callerClient = createClient(SUPABASE_URL, anonKey, {
    auth: { persistSession: false },
    global: { headers: { Authorization: `Bearer ${callerToken}` } },
  });

  const { data, error: authErr } = await callerClient.auth.getUser();
  if (authErr || !data.user) {
    console.warn("send-notification: unauthorized caller");
    return err("Unauthorized", 401);
  }

  // Seguridad: el usuario solo puede enviar notificaciones a sí mismo
  if (data.user.id !== userId) {
    console.warn("send-notification: user trying to notify another user");
    return err("Forbidden", 403);
  }
}
 

  // - 4. Leer tokens del usuario --------------
  const supabase = createClient(SUPABASE_URL, serviceRoleKey);

  const { data: devices, error: dbErr } = await supabase
    .from("user_devices")
    .select("fcm_token")
    .eq("user_id", userId);

  if (dbErr) {
    console.error("send-notification: db error", dbErr.message);
    return err("Database error", 500);
  }

  const tokens: string[] = (devices ?? [])
    .map((d: { fcm_token: string }) => d.fcm_token)
    .filter(Boolean);

  if (tokens.length === 0) {
    return ok({ message: "No registered devices", sent: 0 });
  }

  // - 5. OAuth2 token --------------------
  let accessToken: string;
  try {
    const privateKey = FCM_PRIVATE_KEY.replace(/\\n/g, "\n");
    accessToken = await getFcmAccessToken(FCM_CLIENT_EMAIL, privateKey);
  } catch (e) {
    console.error("send-notification: OAuth2 failed", (e as Error).message);
    return err("Failed to authenticate with FCM", 500);
  }

  // - 6. Enviar -----------------------
  const results = await Promise.all(
    tokens.map((token) =>
      sendToToken(token, title, body, FCM_PROJECT_ID, accessToken)
    )
  );

  const sent = results.filter((r) => r.status === "sent").length;
  const invalid = results.filter((r) => r.status === "invalid");
  const errors = results.filter((r) => r.status === "error");

  // - 7. Limpiar tokens inválidos --------------
  if (invalid.length > 0) {
    const invalidTokens = invalid.map((r) => r.token);
    supabase.from("user_devices").delete()
      .eq("user_id", userId)
      .in("fcm_token", invalidTokens)
      .then(({ error }) => {
        if (error) console.error("send-notification: failed to clean tokens", error.message);
      });
  }

  console.log("send-notification:", {
    userId,
    total: tokens.length,
    sent,
    invalid: invalid.length,
    errors: errors.length,
    errorReasons: errors.map((e) => (e as { reason: string }).reason),
  });

  return ok({ success: true, sent, invalid: invalid.length, errors: errors.length });
});