// Data access for the `projects` collection — the one query behind the /projects/ listing, the
// home Featured Projects grid, and the detail route's getStaticPaths, so their draft filter + sort
// can't drift. Kept separate from projectCards.ts (pure mapping, no astro deps) because this imports
// `getCollection` as a value, which the type-stripped `pnpm test` can't resolve.
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
