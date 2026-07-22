// @ts-check
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "astro/config";

// The production domain, which `site` below feeds to canonical, OG, JSON-LD, the sitemap,
// robots.txt and llms.txt — six things one wrong value poisons at once, and none of them visibly
// broken in review. A fresh clone builds on the placeholder so a buyer can see the site before
// owning a domain; a production deploy refuses to, so the placeholder cannot reach a live domain.
//
// This template is host-agnostic, so "is this a production deploy?" reads each host's own build
// variable rather than assuming one. None of these is set by a local `pnpm build` or by a deploy
// preview, so previews and local work build freely. On a host not listed here, set DEPLOY_ENV
// yourself (see .env.example) — the gate is only as good as the signal it can see.
const site = process.env.SITE_URL ?? "https://example.com";
const isProductionDeploy =
  process.env.CONTEXT === "production" || // Netlify
  process.env.VERCEL_ENV === "production" || // Vercel
  process.env.DEPLOY_ENV === "production"; // anything else — set it in your host's build env

if (isProductionDeploy && site.includes("example.com")) {
  throw new Error(
    "SITE_URL is unset or still the placeholder. Set it to your production domain in your " +
      "host's environment variables before deploying.",
  );
}

// https://astro.build/config
export default defineConfig({
  site,

  // One canonical URL shape: the directory build emits trailing slashes, and canonical + OG agree
  // on that shape (see the project docs).
  trailingSlash: "always",

  // mdx() renders .mdx content.
  // sitemap filter: never list noindex pages — the dev-only /examples catalog and 404s
  // both set `noindex` in the markup, so a sitemap entry for them would contradict it.
  integrations: [
    mdx(),
    sitemap({ filter: (page) => !page.includes("/examples/") && !page.includes("/404/") }),
  ],

  vite: {
    plugins: [tailwindcss()],
    // Stop inlining short scripts so they don't break under <ClientRouter /> view transitions.
    build: {
      assetsInlineLimit: 0,
    },
  },
});
