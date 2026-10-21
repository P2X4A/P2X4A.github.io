import { type NavItemProps } from "./types/configDataTypes";

/**
 * * Primary navigation — the header's link set (Figma node 5:110).
 *
 * Labels are Title-case and uppercased in the UI (Press Start 2P). Hrefs carry the trailing slash
 * to match `astro.config.mjs` `trailingSlash: "always"`. `as const satisfies` keeps the literal
 * types while checking the shape.
 *
 * Order: ABOUT · PROJECTS · CONTACT. Home is intentionally not a nav item — the brand wordmark
 * (Header.astro `<a href="/">`) is the home link, the common logo-as-home pattern. All three routes are
 * live. Three Press Start labels fit the desktop bar at `lg` (measured).
 */
export const navItems = [
  { label: "Presentación", href: "/about/" },
  { label: "Evidencias", href: "/projects/" },
  { label: "Contacto", href: "/contact/" },
] as const satisfies readonly NavItemProps[];