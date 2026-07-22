// Dependency-free RSS 2.0 feed for the blog (seo.md: RSS ships with the blog route; hand-rolled like
// everything else in <head>, no @astrojs/rss). A static endpoint so its absolute URLs resolve against
// `site` and never drift; linked from the footer, BaseHead, and llms.txt.
import { getSortedPosts } from "@components/Sections/Blog/blogData";
import siteData from "@config/siteData.json";
import { siteLocale } from "@config/siteSettings.json";
import type { APIContext } from "astro";

/** Escape the five XML predefined entities so a title/description can't break the document. */
function escapeXml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

export async function GET({ site }: APIContext): Promise<Response> {
  if (!site) {
    throw new Error("`site` must be set in astro.config.mjs for the RSS feed to resolve URLs.");
  }

  const posts = await getSortedPosts();
  const items = posts
    .map((post) => {
      const url = new URL(`/blog/${post.id}/`, site).href;
      return `    <item>
      <title>${escapeXml(post.data.title)}</title>
      <link>${url}</link>
      <guid isPermaLink="true">${url}</guid>
      <description>${escapeXml(post.data.description)}</description>
      <pubDate>${post.data.pubDate.toUTCString()}</pubDate>
    </item>`;
    })
    .join("\n");

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>${escapeXml(siteData.name)}</title>
    <link>${new URL("/blog/", site).href}</link>
    <description>${escapeXml(siteData.description)}</description>
    <language>${siteLocale}</language>
${items}
  </channel>
</rss>`;

  return new Response(xml, {
    headers: { "Content-Type": "application/xml; charset=utf-8" },
  });
}
