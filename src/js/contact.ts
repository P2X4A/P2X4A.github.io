/**
 * * Contact form — the trust boundary.
 *
 * Pure and framework-free on purpose: no `import.meta.env`, no `fetch`, no Astro imports — so it
 * type-strips for `pnpm test` AND bundles straight into the browser script that validates the form.
 * One Zod schema is the ONLY definition of a valid submission.
 *
 * The site is deployed 100% to GitHub Pages — a static host with no server to receive a POST — so the
 * form validates in the browser and hands the visitor a prefilled `mailto:` link. The plain address
 * is the no-JS fallback and already sits on the page in the info cards. The spam gates (honeypot +
 * time) still run, client side: they stop the naive autofill bots, not a determined one.
 */
import { z } from "astro/zod";

/**
 * Reject CR/LF: `name` and `subject` are the two fields that reach the mail subject line, so a line
 * break in either is a header-injection attempt. We reject rather than strip so the visitor sees why.
 */
const noLineBreaks = (value: string): boolean => !/[\r\n]/.test(value);

/** The single source of truth for a valid submission. The two hidden fields feed the spam gates. */
export const contactSchema = z.object({
  name: z
    .string()
    .trim()
    .min(1, "Enter your name, player.")
    .max(100, "That name is too long.")
    .refine(noLineBreaks, "Line breaks are not allowed here."),
  email: z.string().trim().pipe(z.email("Please enter a valid email address.").max(254)),
  subject: z
    .string()
    .trim()
    .min(1, "Give your transmission a subject.")
    .max(150, "That subject is too long.")
    .refine(noLineBreaks, "Line breaks are not allowed here."),
  message: z
    .string()
    .trim()
    .min(10, "Tell me a little more than that.")
    .max(5000, "That transmission is too long."),
  /** Honeypot — permissive on purpose, so a filled value becomes a readable form-level rejection. */
  _gotcha: z.string().optional(),
  /** Load timestamp for the time gate; coerced from the hidden field's string. */
  _ts: z.coerce.number().int().positive(),
});

export type ContactInput = z.infer<typeof contactSchema>;

/** Minimum ms between load and submit. Faster than a human can read the form ⇒ a bot. */
export const MIN_FILL_MS = 3000;

/**
 * * Spam gates, cheapest first: honeypot then time. Returns a rejection reason, or `null` to proceed.
 *
 * The time gate has no upper bound (a form left open an hour still submits) and `_ts` is a forgeable
 * hidden field: this stops drive-by bots, not a targeted attacker. It also costs the no-JS path,
 * which never runs it — deliberately left out of the static flow.
 *
 * @param fields the two hidden anti-spam fields
 * @param now    current epoch ms (injectable for the self-check)
 * @returns a reason string to reject, or `null` when the submission clears both gates
 */
export function spamReason(
  { _gotcha, _ts }: Pick<ContactInput, "_gotcha" | "_ts">,
  now: number = Date.now(),
): string | null {
  if (_gotcha) return "Message rejected.";
  if (now - _ts < MIN_FILL_MS) return "That was quick — please take another look and resend.";
  return null;
}

/**
 * * Build the prefilled `mailto:` URL the browser hands to the visitor's mail client — the static
 * host's stand-in for the POST the old server action used to receive.
 *
 * Everything is percent-encoded by `URLSearchParams`, so a newline or an `&` inside the message can
 * never break out of the query string and inject a second parameter.
 *
 * @param fields    the validated name/email/subject/message
 * @param recipient the mailbox the message is addressed to
 * @param siteName  the brand, prefixed to the subject line
 */
export function buildMailtoUrl(
  { name, email, subject, message }: Pick<ContactInput, "name" | "email" | "subject" | "message">,
  recipient: string,
  siteName: string,
): string {
  const body = [
    `Name: ${name}`,
    `Email: ${email}`,
    `Subject: ${subject}`,
    "",
    message,
  ].join("\n");
  const params = new URLSearchParams({
    subject: `[${siteName}] ${subject} — ${name}`,
    body,
  });
  return `mailto:${recipient}?${params.toString()}`;
}
