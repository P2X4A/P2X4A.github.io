import { type SiteDataProps } from "./types/configDataTypes";

// Site metadata. Edit with your project's details.
const siteData = {
name: "Sergio Parra",
title: "Sergio Parra — Portafolio",
description:
  "Portafolio de Sergio Parra, estudiante de Ingeniería de Sistemas interesado en el desarrollo de software, programación y tecnología.",

  author: {
    name: "Sergio Parra",
    email: "sparrar@unbosque.edu.co",
    // Ships EMPTY on purpose: BaseHead only emits `twitter:creator` when this is set, so an unfilled
    // template omits the tag rather than attributing every page to a handle that doesn't exist.
    twitter: "",
  },

  defaultImage: {
    src: "/og.jpg",
alt: "Portafolio de Sergio Parra",
  },

  // Social/profile URLs, surfaced as the Organization `sameAs` in JSON-LD (see @js/schema) AND used
  // by @config/socialData to point the footer row, the home contact chips and the contact InfoCards
  // at your real profiles. **Fill this before launch:** while it is empty those links fall back to
  // bare platform home pages (github.com, linkedin.com, discord.gg, …).
  // e.g. ["https://x.com/yourhandle", "https://github.com/yourorg"]
sameAs: [
  "https://github.com/P2X4A",
],
} satisfies SiteDataProps;

export default siteData;
