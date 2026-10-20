// Shared project → card mapping for the listing grid (Sections/Project) and the home Featured
// Projects section, so the two grids can't drift. Pure data-shaping — the only runtime module the
// two Astro files import; its check lives beside it (projectCards.test.ts).
//
// All imports below are type-only, so `pnpm test` (Node type-stripping) erases them and this file
// runs with no bundler / no astro: virtual-module resolution. Keep them type-only.
import type { ContentCardProps } from "@components/Cards/ContentCard.astro";
import type { BadgeVariant } from "@components/ui/badge";
import type { CollectionEntry } from "astro:content";

export type ProjectStatus = "complete" | "in-progress";

/**
 * A project's `status` → its retro card badge: label + a ui/badge tone.
 * COMPLETE reads green (success), IN PROGRESS amber (warning) — the Figma "Status Tag" colours.
 *
 * @param status the entry's `status` field
 * @returns the badge label (bracketed, retro) and the tone variant
 */
export function statusMeta(status: ProjectStatus): { label: string; variant: BadgeVariant } {
  return status === "complete"
    ? { label: "[Complete]", variant: "success" }
    : { label: "[In Progress]", variant: "warning" };
}

/**
 * Map a `projects` collection entry to the shared ContentCard props used by both project grids.
 * The card title falls back to the canonical `title` when the entry omits the shorter `cardTitle`.
 *
 * @param entry a `projects` collection entry
 * @returns props ready to spread into `<ContentCard />`
 * @example toProjectCard(entry).href; // "/projects/realtime-chat/"
 */
export function toProjectCard(entry: CollectionEntry<"projects">): ContentCardProps {
  const { data } = entry;
  const { label, variant } = statusMeta(data.status);
  return {
    href: `/projects/${entry.id}/`,
    image: data.thumbnail,
    imageAlt: data.thumbnailAlt,
    badgeLabel: label,
    badgeVariant: variant,
    title: data.cardTitle ?? data.title,
    description: data.description,
    tags: data.tech,
    cta: "View",
  };
}

/**
 * Pick the `limit` most recently added projects, newest first.
 *
 * `order` is the upload chronology — the /projects/ listing walks it ascending (oldest first) and
 * each new entry takes the next number — so the most recent uploads are the ones with the HIGHEST
 * order. The home "Últimos proyectos" grid wants them in the opposite direction: newest leads.
 *
 * Pure and side-effect free: it copies before sorting, so the caller's array (and the shared
 * listing order) is never mutated.
 *
 * @param entries the project entries to pick from
 * @param limit   how many to return
 * @returns at most `limit` entries, newest first
 */
export function pickLatestProjects<T extends { data: { order: number } }>(
  entries: readonly T[],
  limit: number,
): T[] {
  return [...entries].sort((a, b) => b.data.order - a.data.order).slice(0, limit);
}
