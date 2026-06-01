import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    // 1. Verificar sesión
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return json({ error: "No authorization header" }, 401);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) return json({ error: "Unauthorized" }, 401);

    // 2. Leer keyLocal del body (base64, 32 bytes)
    const body = await req.json();
    const keyLocalBase64 = body?.key_local;

    if (!keyLocalBase64 || typeof keyLocalBase64 !== "string") {
      return json({ error: "Missing key_local in body" }, 400);
    }

    const keyLocalBytes = base64ToBytes(keyLocalBase64);
    if (keyLocalBytes.length !== 32) {
      return json({ error: "key_local must be 32 bytes" }, 400);
    }

    // 3. Leer master key
    const masterKeyHex = Deno.env.get("ALMA_MASTER_KEY");
    if (!masterKeyHex) return json({ error: "Master key not configured" }, 500);
    const masterKeyBytes = hexToBytes(masterKeyHex);

    // 4. Cifrar keyLocal con masterKey usando AES-256-GCM
    const wrappedKey = await wrapKey(masterKeyBytes, keyLocalBytes);

    // 5. Guardar en profiles.wrapped_key usando service role
    // (el usuario autenticado no tiene permiso de escritura directa en esta columna)
    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { error: updateError } = await adminClient
      .from("profiles")
      .update({ wrapped_key: wrappedKey })
      .eq("id", user.id);

    if (updateError) {
      console.error("wrap-key: failed to save wrapped_key", updateError);
      return json({ error: "Failed to save wrapped key" }, 500);
    }

    console.log(`wrap-key: key wrapped and saved for user ${user.id.substring(0, 8)}…`);
    return json({ success: true }, 200);

  } catch (err) {
    console.error("wrap-key error:", err);
    return json({ error: "Internal server error" }, 500);
  }
});

// ─── AES-256-GCM wrap ────────────────────────────────────────────────────────

async function wrapKey(masterKey: Uint8Array, keyLocal: Uint8Array): Promise<string> {
  const iv = crypto.getRandomValues(new Uint8Array(12));

  const masterCryptoKey = await crypto.subtle.importKey(
    "raw", masterKey,
    { name: "AES-GCM" },
    false,
    ["encrypt"]
  );

  const cipherBytes = await crypto.subtle.encrypt(
    { name: "AES-GCM", iv, tagLength: 128 },
    masterCryptoKey,
    keyLocal
  );

  // Formato: iv_base64.cipher_base64 — mismo patrón que CipherBundle en Dart
  return `${bytesToBase64(iv)}.${bytesToBase64(new Uint8Array(cipherBytes))}`;
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}

function hexToBytes(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < hex.length; i += 2) {
    bytes[i / 2] = parseInt(hex.slice(i, i + 2), 16);
  }
  return bytes;
}

function base64ToBytes(b64: string): Uint8Array {
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

function bytesToBase64(bytes: Uint8Array): string {
  return btoa(String.fromCharCode(...bytes));
}