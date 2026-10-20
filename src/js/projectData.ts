// Data access for the `projects` collection — the one query behind the /projects/ listing, the
// home Featured Projects grid, and the detail route's getStaticPaths, so their draft filter + sort
// can't drift. Kept separate from projectCards.ts (pure mapping, no astro deps) because this imports
// `getCollection` as a value, which the type-stripped `pnpm test` can't resolve.
import { pickLatestProjects } from "@js/projectCards";
import { type CollectionEntry, getCollection } from "astro:content";

/**
 * Published `projects` entries, sorted by `order` ascending.
 *
 * @returns the non-draft project entries in listing order
 */
export async function getSortedProjects(): Promise<CollectionEntry<"projects">[]> {
  const projects = await getCollection("projects", ({ data }) => data.draft !== true);
  return projects.sort((a, b) => a.data.order - b.data.order);
}

/**
 * Published `projects` entries of one category, sorted by `order` ascending.
 *
 * @param category one of "modelado" | "normalizacion" | "sql" | "proyecto"
 * @returns the non-draft entries of that category in listing order
 */
export async function getProjectsByCategory(
  category: CollectionEntry<"projects">["data"]["category"],
): Promise<CollectionEntry<"projects">[]> {
  const projects = await getSortedProjects();
  return projects.filter((entry) => entry.data.category === category);
}

/**
 * The most recently added projects, newest first.
 *
 * `order` is the upload chronology, so the latest uploads are the ones with the highest order —
 * the opposite end of the list the /projects/ grid walks. The home "Últimos proyectos" section
 * takes the head of this list, so the newest upload leads the row.
 *
 * @param limit how many to return (default 3)
 * @returns at most `limit` entries, newest first
 */
export async function getLatestProjects(
  limit = 3,
): Promise<CollectionEntry<"projects">[]> {
  return pickLatestProjects(await getSortedProjects(), limit);
}
