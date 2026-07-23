import { type SiteDataProps } from "./types/configDataTypes";

// Site metadata. Edit with your project's details.
const siteData = {
  name: "8-BitQuest",
  title: "8-BitQuest — retro pixel-art dev portfolio",
  description:
    "A retro 8-bit, pixel-art developer portfolio built on Astro 7 and a CSS-first Tailwind v4 token system.",

  author: {
    name: "Your Name",
    email: "you@example.com",
    twitter: "yourhandle",
  },

  defaultImage: {
    src: "/og.jpg",
    alt: "8-BitQuest",
  },

  // social/profile URLs, surfaced as the Organization `sameAs` in JSON-LD (see @js/schema).
  // e.g. ["https://x.com/yourhandle", "https://github.com/yourorg"]
  sameAs: [],
} satisfies SiteDataProps;

export default siteData;
