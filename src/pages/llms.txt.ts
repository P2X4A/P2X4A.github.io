import siteData from "@config/siteData.json";
import type { APIRoute } from "astro";

/**
 * /llms.txt — a machine-readable content map for AI retrieval systems (llmstxt.org).
 * Not a ranking factor; a curated index of what's worth reading. Dynamic so links stay
 * absolute and in sync with `site` + siteData. Prerenders to a static file at build.
 *
 * ponytail: hand-curated stub — as the site grows (blog, docs, RSS), add the important
 * entry points here. It's an editorial map, not an auto-generated sitemap. See the project docs.
 */
export const GET: APIRoute = ({ site }) => {
  const { name, description } = siteData;
  const base = site ?? new URL("https://example.com/");

  const body = [
    `# ${name}`,
    "",
    `> ${description}`,
    "",
    "## Core pages",
    `- [Home](${base.href})`,
    `- [Terms](${new URL("terms/", base).href})`,
    `- [Privacy](${new URL("privacy/", base).href})`,
    "",
  ].join("\n");

  return new Response(body, { headers: { "Content-Type": "text/plain; charset=utf-8" } });
};
