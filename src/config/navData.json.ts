import { type NavItemProps } from "./types/configDataTypes";

/**
 * * Primary navigation — the header's link set (Figma node 5:110).
 *
 * Labels are Title-case and uppercased in the UI (Press Start 2P). Hrefs carry the trailing slash
 * to match `astro.config.mjs` `trailingSlash: "always"`. `as const satisfies` keeps the literal
 * types while checking the shape.
 *
 * NOTE: only `/` ships today. `/blog/`, `/about/`, and `/contact/` are the site's intended routes
 * and will 404 until their pages land (the blog route is a deliberate later-build per the project docs).
 */
export const navItems = [
  { label: "Home", href: "/" },
  { label: "Blog", href: "/blog/" },
  { label: "About", href: "/about/" },
  { label: "Contact", href: "/contact/" },
] as const satisfies readonly NavItemProps[];
