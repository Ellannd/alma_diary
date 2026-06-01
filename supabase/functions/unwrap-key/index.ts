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
    if (!authHeader) return json({ error: "No authorization header" }, 401);

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) return json({ error: "Unauthorized" }, 401);

    // 2. Leer wrapped_key de profiles
    const adminClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: profile, error: profileError } = await adminClient
      .from("profiles")
      .select("wrapped_key")
      .eq("id", user.id)
      .single();

    if (profileError || !profile?.wrapped_key) {
      return json({ error: "No wrapped key found for user" }, 404);
    }

    // 3. Leer master key y descifrar
    const masterKeyHex = Deno.env.get("ALMA_MASTER_KEY");
    if (!masterKeyHex) return json({ error: "Master key not configured" }, 500);
    const masterKeyBytes = hexToBytes(masterKeyHex);

    const keyLocalBytes = await unwrapKey(masterKeyBytes, profile.wrapped_key);
    const keyLocalBase64 = bytesToBase64(keyLocalBytes);

    // Log auditable — nunca loguear la key completa
    console.log(`unwrap-key: key recovered for user ${user.id.substring(0, 8)}…`);

    return json({ key_local: keyLocalBase64 }, 200);

  } catch (err) {
    console.error("unwrap-key error:", err);
    return json({ error: "Internal server error" }, 500);
  }
});

// ─── AES-256-GCM unwrap ───────────────────────────────────────────────────────

async function unwrapKey(masterKey: Uint8Array, wrapped: string): Promise<Uint8Array> {
  const parts = wrapped.split(".");
  if (parts.length !== 2) throw new Error("Invalid wrapped key format");

  const iv = base64ToBytes(parts[0]);
  const cipherBytes = base64ToBytes(parts[1]);

  const masterCryptoKey = await crypto.subtle.importKey(
    "raw", masterKey,
    { name: "AES-GCM" },
    false,
    ["decrypt"]
  );

  const plainBytes = await crypto.subtle.decrypt(
    { name: "AES-GCM", iv, tagLength: 128 },
    masterCryptoKey,
    cipherBytes
  );

  return new Uint8Array(plainBytes);
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