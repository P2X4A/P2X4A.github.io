import { type SiteDataProps } from "./types/configDataTypes";

// Site metadata. Edit with your project's details.
const siteData: SiteDataProps = {
  name: "Astro Boiler",
  title: "Astro Boiler — Astro 7 + Tailwind v4 starter",
  description:
    "A lean Astro 7 starter with a CSS-first Tailwind v4 token architecture and typed, config-driven content, ready to grow into your own template.",

  author: {
    name: "Your Name",
    email: "you@example.com",
    twitter: "yourhandle",
  },

  defaultImage: {
    src: "/og.jpg",
    alt: "Astro Boiler",
  },

  // social/profile URLs, surfaced as the Organization `sameAs` in JSON-LD (see @js/schema).
  // e.g. ["https://x.com/yourhandle", "https://github.com/yourorg"]
  sameAs: [],
};

export default siteData;
