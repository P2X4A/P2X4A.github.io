/**
 * * Astro Actions — the one server mutation in 8-BitQuest: the contact form (the grafio pattern).
 *
 * `accept: "form"` binds the action to a native `<form method="POST">`, so it works with JavaScript
 * disabled: the browser posts real FormData, Astro runs `contactSchema` first (the handler starts
 * from valid data), and `/contact/` re-renders with the result. Non-validation failures are thrown as
 * `ActionError`s whose message the page surfaces in one `role="alert"`; validation failures surface
 * per-field via `isInputError`. The Resend send itself lives in `@js/resend` (a tested, framework-free
 * boundary); here we translate its result — logging the provider detail server-side (it can name the
 * account, so it never reaches the visitor) and throwing a generic ActionError on any failure.
 */
import siteData from "@config/siteData.json";
import { buildEmail, contactSchema, spamReason } from "@js/contact";
import { sendContactEmail } from "@js/resend";
import { ActionError, defineAction } from "astro:actions";

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

      // 3. Build (escaped) + send via the Resend boundary, then translate the result.
      const result = await sendContactEmail(buildEmail(input, siteData.name), { apiKey, to, from });
      if (!result.ok) {
        // Log the provider's real answer (it can name the account); never show it to the visitor.
        const context = result.reason === "provider" ? `provider ${result.status}` : result.reason;
        console.error(`[contact] Resend send failed (${context}):`, result.detail);
        throw new ActionError({
          code: "INTERNAL_SERVER_ERROR",
          message: "Your message could not be sent. Please email me directly.",
        });
      }

      return { ok: true as const };
    },
  }),
};
