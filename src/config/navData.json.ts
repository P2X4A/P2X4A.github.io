import { type NavItemProps } from "./types/configDataTypes";

/**
 * * Primary navigation — the header's link set (Figma node 5:110).
 *
 * Labels are Title-case and uppercased in the UI (Press Start 2P). Hrefs carry the trailing slash
 * to match `astro.config.mjs` `trailingSlash: "always"`. `as const satisfies` keeps the literal
 * types while checking the shape.
 *
 * The link set matches the Figma frames (nodes 72:7 / 72:191): HOME · PROJECTS · ABOUT · CONTACT.
 * PROJECTS took the slot the mock gives it (the frames omit Blog); `/`, `/projects/`, and `/about/`
 * are live pages, `/contact/` is the one intended route that still 404s until it lands. Blog stays
 * reachable off the home READ BLOG CTA + the footer RSS link — it just isn't top-nav chrome here.
 */
export const navItems = [
  { label: "Home", href: "/" },
  { label: "Projects", href: "/projects/" },
  { label: "About", href: "/about/" },
  { label: "Contact", href: "/contact/" },
] as const satisfies readonly NavItemProps[];
