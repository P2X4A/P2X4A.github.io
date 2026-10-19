// Run: pnpm test  (or: node --experimental-strip-types src/js/contact.test.ts)
// The runnable check behind the contact form's trust boundary: schema accept/reject, the two spam
// gates, header-injection rejection, and the prefilled mailto link the static site hands over. No
// framework, no fixtures.
import assert from "node:assert/strict";

import { buildMailtoUrl, contactSchema, MIN_FILL_MS, spamReason } from "./contact.ts";

const valid = {
  name: "Player One",
  email: "player1@example.com",
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
const loaded = 10_000;
assert.ok(spamReason({ _ts: loaded }, loaded + MIN_FILL_MS - 1) !== null);
assert.equal(spamReason({ _ts: loaded }, loaded + MIN_FILL_MS), null);

// the mailto link addresses the recipient and carries the branded subject
const url = buildMailtoUrl(
  {
    name: "Player One",
    email: "player1@example.com",
    subject: "Tutorial inquiry",
    message: "I would love a devlog on dithering.",
  },
  "sparrar@unbosque.edu.co",
  "8-BitQuest",
);
assert.ok(url.startsWith("mailto:sparrar@unbosque.edu.co?"));
const params = new URLSearchParams(url.slice(url.indexOf("?") + 1));
assert.equal(params.get("subject"), "[8-BitQuest] Tutorial inquiry — Player One");

// ...and the whole message in the body, with the sender's address so the reply reaches them
const body = params.get("body") ?? "";
assert.ok(body.includes("Name: Player One"));
assert.ok(body.includes("Email: player1@example.com"));
assert.ok(body.includes("Subject: Tutorial inquiry"));
assert.ok(body.includes("I would love a devlog on dithering."));

// the query string is encoded: a newline or an ampersand in the message can't break out of it
const tricky = buildMailtoUrl(
  { name: "A & B", email: "a@b.co", subject: "Hi <there>", message: "line1\nline2 & line3" },
  "x@y.co",
  "Site",
);
assert.ok(!tricky.includes("\n"));
assert.ok(tricky.includes("%26")); // the ampersand is encoded, not a parameter separator
assert.ok(tricky.includes("%0A")); // the newline is encoded too
const trickyParams = new URLSearchParams(tricky.slice(tricky.indexOf("?") + 1));
assert.ok((trickyParams.get("body") ?? "").includes("line1\nline2 & line3"));

console.log("contact: all assertions passed");
