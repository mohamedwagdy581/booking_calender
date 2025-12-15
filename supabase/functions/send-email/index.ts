
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { Resend } from "npm:resend";

// This is the main function that will be called by your Flutter app.
serve(async (req) => {
  try {
    // The 'email', 'subject', and 'message' are sent from your app.
    const { email, subject, message } = await req.json();

    // We get the Resend API key from the secrets you will set up in Supabase.
    const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

    // Here, we are sending the email using Resend.
    const { data, error } = await resend.emails.send({
      // IMPORTANT: You will need to replace this with an email address
      // you have verified in your Resend account.
      from: "Dimah Music <mw41532@gmail.com>",
      to: [email],
      subject: subject,
      html: `<strong>${message}</strong>`,
    });

    // If there is an error, we return it to the app.
    if (error) {
      console.error({ error });
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    // If the email is sent successfully, we return the success message.
    return new Response(JSON.stringify(data), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    // If there is any other error, we return it.
    return new Response(String(err?.message ?? err), { status: 500 });
  }
});
