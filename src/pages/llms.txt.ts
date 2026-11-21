import siteData from "@config/siteData.json";
import type { APIRoute } from "astro";

/**
 * /llms.txt — a plain-text index of the site's main pages (llmstxt.org). Dynamic so links
 * stay absolute and in sync with `site` + siteData. Prerenders to a static file at build.
 *
 * Note: hand-curated, not an auto-generated sitemap — add new top-level entry points here as
 * the site grows, or this drifts. Currently the main pages and the legal documents.
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
    `- [About](${new URL("about/", base).href})`,
    `- [Projects](${new URL("projects/", base).href})`,
    `- [Contact](${new URL("contact/", base).href})`,
    "",
    "## Legal",
    `- [Terms](${new URL("terms/", base).href})`,
    `- [Privacy](${new URL("privacy/", base).href})`,
    "",
  ].join("\n");

  return new Response(body, { headers: { "Content-Type": "text/plain; charset=utf-8" } });
};
