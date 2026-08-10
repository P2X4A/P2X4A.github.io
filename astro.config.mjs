// @ts-check
import cloudflare from "@astrojs/cloudflare";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig, envField } from "astro/config";

// Dominio de producción: úsalo para canonical, OG, sitemap, robots, etc.
const site = process.env.SITE_URL ?? "https://p2x4a.github.io";

// Detectar si es un deploy de producción (no afecta GitHub Pages por ahora,
// pero dejamos la lógica original por si luego migras a otro host).
const isProductionDeploy =
  process.env.CONTEXT === "production" || // Netlify
  process.env.VERCEL_ENV === "production" || // Vercel
  process.env.DEPLOY_ENV === "production"; // otro host (si defines DEPLOY_ENV)

// Hosts de placeholder
const placeholderHosts = new Set(["example.com", "www.example.com"]);
const hostname = URL.canParse(site) ? new URL(site).hostname : "example.com";
if (isProductionDeploy && placeholderHosts.has(hostname)) {
  throw new Error(
    "SITE_URL is unset or still the placeholder. Set it to your production domain in your " +
      "host's environment variables before deploying.",
  );
}

// [https://astro.build/config](https://astro.build/config)
export default defineConfig({
  site,

  // Adaptador Cloudflare, como en la plantilla original
  adapter: cloudflare(),

  // Variables de entorno para el formulario de contacto (opcionales)
  env: {
    schema: {
      RESEND_API_KEY: envField.string({ context: "server", access: "secret", optional: true }),
      CONTACT_TO_EMAIL: envField.string({ context: "server", access: "secret", optional: true }),
      CONTACT_FROM_EMAIL: envField.string({ context: "server", access: "secret", optional: true }),
    },
  },

  // URLs con barra final
  trailingSlash: "always",

  // Integraciones
  integrations: [
    mdx(),
    sitemap({
      filter: (page) => !page.includes("/examples/") && !page.includes("/404/"),
      customPages: [new URL("/contact/", site).href],
    }),
  ],

  vite: {
    plugins: [tailwindcss()],
    // No inlines de scripts cortos (para que no se rompan con view transitions)
    build: {
      assetsInlineLimit: 0,
    },
  },
});