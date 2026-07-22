// Run: pnpm test  (or: node --experimental-strip-types src/js/contact.test.ts)
// The runnable check behind the contact form's trust boundary: schema accept/reject, the two spam
// gates, header-injection rejection, and email-body escaping. No framework, no fixtures.
import assert from "node:assert/strict";

import { buildEmail, contactSchema, escapeHtml, MIN_FILL_MS, spamReason } from "./contact.ts";

const valid = {
  name: "Alex Chen",
  email: "player1@genesis.com",
  subject: "Tutorial inquiry",
  message: "I would love a devlog on dithering.",
  _ts: 1000,
};

// schema accepts a good submission and coerces the hidden timestamp from its string form
const ok = contactSchema.safeParse({ ...valid, _ts: "1000" });
assert.equal(ok.success, true);
assert.equal(ok.success && ok.data._ts, 1000);

// schema rejects a bad email and a too-short message
assert.equal(contactSchema.safeParse({ ...valid, email: "not-an-email" }).success, false);
assert.equal(contactSchema.safeParse({ ...valid, message: "too short" }).success, false);

// header-injection guard: a line break in name or subject is rejected, not stripped
assert.equal(contactSchema.safeParse({ ...valid, name: "Alex\r\nBcc: x@y.z" }).success, false);
assert.equal(contactSchema.safeParse({ ...valid, subject: "Hi\nBcc: x@y.z" }).success, false);

// spam gate — honeypot: any non-empty _gotcha rejects
assert.equal(spamReason({ _gotcha: "i-am-a-bot", _ts: 0 }, 10_000), "Message rejected.");

// spam gate — time: a submit faster than MIN_FILL_MS rejects; slower passes
const rendered = 10_000;
assert.ok(spamReason({ _ts: rendered }, rendered + MIN_FILL_MS - 1) !== null);
assert.equal(spamReason({ _ts: rendered }, rendered + MIN_FILL_MS), null);

// email body escapes HTML so a field can't inject markup, and the reply-to is the sender's address
const mail = buildEmail(
  { name: "<script>", email: "a@b.co", subject: "Hi & bye", message: "1 < 2" },
  "8-BitQuest",
);
assert.equal(mail.replyTo, "a@b.co");
assert.ok(mail.subject.startsWith("[8-BitQuest] Hi & bye — <script>")); // subject is a header, not HTML
assert.ok(mail.html.includes("&lt;script&gt;"));
assert.ok(mail.html.includes("1 &lt; 2"));
assert.ok(!mail.html.includes("<script>"));

// escapeHtml covers all five significant characters
assert.equal(escapeHtml(`&<>"'`), "&amp;&lt;&gt;&quot;&#39;");

console.log("contact: all assertions passed");
