import { createClient } from "jsr:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {

  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };

  if (req.method === "OPTIONS") {
    return new Response("ok", { status: 200, headers: corsHeaders });
  }

  const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
  const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

  const FCM_SERVER_KEY = Deno.env.get("FCM_SERVER_KEY");

  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY || !FCM_SERVER_KEY) {
    return new Response(
      JSON.stringify({ error: "Missing env vars" }),
      { status: 500, headers: corsHeaders }
    );
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    const { userId, title, body } = await req.json();
    let devices: any[] = [];

    try {
      const { data, error } = await supabase
        .from("user_devices")
        .select("fcm_token")
        .eq("user_id", userId);

      if (error) throw error;

      devices = data ?? [];
    } catch (e) {
      console.error("DB error:", e);

      return new Response(JSON.stringify({ error: "DB failure" }), {
        status: 500,
        headers: corsHeaders,
      });
    }

    const tokens = devices.map((d) => d.fcm_token).filter(Boolean);

    if (tokens.length === 0) {
      return new Response(JSON.stringify({ message: "No tokens" }), {
        status: 200,
        headers: corsHeaders,
      });
    }

    const response = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `key=${FCM_SERVER_KEY}`,
      },
      body: JSON.stringify({
        registration_ids: tokens,
        notification: {
          title,
          body,
          sound: "default",
        },
      }),
    });

    const result = await response.json();

    if (!response.ok) {
      return new Response(
        JSON.stringify({
          error: "FCM failed",
          details: result,
        }),
        {
          status: 500,
          headers: corsHeaders,
        }
      );
    }

    console.log("FCM RESPONSE:", result);
    console.log(" TOKENS SENT:", tokens.length);

    return new Response(
      JSON.stringify({
        success: true,
        sent: tokens.length,
        fcm: result,
      }),
      {
        status: 200,
        headers: corsHeaders,
      }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      {
        status: 500,
        headers: corsHeaders,
      }
    );
  }
});