import { type NavItemProps } from "./types/configDataTypes";

/**
 * * Primary navigation — the header's link set (Figma node 5:110).
 *
 * Labels are Title-case and uppercased in the UI (Press Start 2P). Hrefs carry the trailing slash
 * to match `astro.config.mjs` `trailingSlash: "always"`. `as const satisfies` keeps the literal
 * types while checking the shape.
 *
 * Order: ABOUT · PROJECTS · BLOG · CONTACT. Home is intentionally not a nav item — the brand wordmark
 * (Header.astro `<a href="/">`) is the home link, the common logo-as-home pattern. `/about/`,
 * `/projects/`, and `/blog/` are live pages; `/contact/` is the one intended route that still 404s
 * until it lands. Four Press Start labels fit the desktop bar at `lg` (measured).
 */
export const navItems = [
  { label: "About", href: "/about/" },
  { label: "Projects", href: "/projects/" },
  { label: "Blog", href: "/blog/" },
  { label: "Contact", href: "/contact/" },
] as const satisfies readonly NavItemProps[];
