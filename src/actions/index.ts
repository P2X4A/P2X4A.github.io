/**
 * * Astro Actions — the one server mutation in 8-BitQuest: the contact form (the grafio pattern).
 *
 * `accept: "form"` binds the action to a native `<form method="POST">`, so it works with JavaScript
 * disabled: the browser posts real FormData, Astro runs `contactSchema` first (the handler starts
 * from valid data), and `/contact/` re-renders with the result. Non-validation failures are thrown as
 * `ActionError`s whose message the page surfaces in one `role="alert"`; validation failures surface
 * per-field via `isInputError`. Nothing here leaks Resend's own response to the visitor — it can name
 * the account, so it's logged server-side only.
 */
import siteData from "@config/siteData.json";
import { buildEmail, contactSchema, spamReason } from "@js/contact";
import { ActionError, defineAction } from "astro:actions";

const RESEND_ENDPOINT = "https://api.resend.com/emails";
const SEND_TIMEOUT_MS = 10_000;

export const server = {
  contact: defineAction({
    accept: "form",
    input: contactSchema,
    handler: async (input) => {
      // 1. Spam gates (honeypot + time). Server clock — never the visitor's device.
      const reason = spamReason(input);
      if (reason) throw new ActionError({ code: "BAD_REQUEST", message: reason });

      // 2. Mail keys — checked at REQUEST time, so a missing key never breaks the build.
      const apiKey = import.meta.env.RESEND_API_KEY;
      const to = import.meta.env.CONTACT_TO_EMAIL;
      if (!apiKey || !to) {
        throw new ActionError({
          code: "INTERNAL_SERVER_ERROR",
          message:
            "This form is not configured yet. Set RESEND_API_KEY and CONTACT_TO_EMAIL — see .env.example.",
        });
      }
      // Defaults to Resend's shared sender, which only delivers to the account owner's address.
      // Verify your own domain in Resend and set CONTACT_FROM_EMAIL to send anywhere.
      const from = import.meta.env.CONTACT_FROM_EMAIL ?? "onboarding@resend.dev";

      // 3. Build (escaped) + send. A plain fetch to Resend — no SDK, no dependency — with a 10s cap.
      const { subject, html, replyTo } = buildEmail(input, siteData.name);
      const sendFailed = "Your message could not be sent. Please email me directly.";
      let res: Response;
      try {
        res = await fetch(RESEND_ENDPOINT, {
          method: "POST",
          headers: {
            Authorization: `Bearer ${apiKey}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ from, to, subject, html, reply_to: replyTo }),
          signal: AbortSignal.timeout(SEND_TIMEOUT_MS),
        });
      } catch (e) {
        console.error("[contact] Resend request failed:", e);
        throw new ActionError({ code: "INTERNAL_SERVER_ERROR", message: sendFailed });
      }
      if (!res.ok) {
        // Log the provider's real answer (it can name the account); never show it to the visitor.
        console.error(
          `[contact] Resend responded ${res.status}:`,
          await res.text().catch(() => ""),
        );
        throw new ActionError({ code: "INTERNAL_SERVER_ERROR", message: sendFailed });
      }

      return { ok: true as const };
    },
  }),
};
