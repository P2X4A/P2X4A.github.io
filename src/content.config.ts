import { glob } from "astro/loaders";
import { z } from "astro/zod";
import { defineCollection, reference } from "astro:content";

/**
 * Content collections. Entries live directly under the collection dir:
 *   src/data/blog/<slug>/index.md   (entry id => "<slug>")
 * (If you re-add i18n, nest per-locale folders — `<locale>/<slug>` ids — and restore a
 * language filter; the removed helpers are in git history.)
 *
 * .mdx posts render via `@astrojs/mdx`, already wired in astro.config.mjs.
 */
const blogCollection = defineCollection({
  loader: glob({ pattern: "**/[^_]*{md,mdx}", base: "./src/data/blog" }),
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      description: z.string(),
      authors: z.array(reference("authors")),
      pubDate: z
        .string()
        .or(z.date())
        .transform((val) => new Date(val)),
      updatedDate: z
        .string()
        .optional()
        .transform((str) => (str ? new Date(str) : undefined)),
      // optional in the starter so example posts need no bundled asset; make it required for real blogs
      heroImage: image().optional(),
      categories: z.array(z.string()).optional(),
      // To pair posts across locales (for a content-aware language switcher), add an optional
      // `mappingKey: z.string().optional()` here and give both translations the same value.
      draft: z.boolean().optional(),
    }),
});

/**
 * Projects — the "Project Log" (Figma node 72:7) + per-project detail pages (node 72:191).
 * Entries live at src/data/projects/<slug>/index.mdx (entry id => "<slug>").
 *
 * The free-form "Project Overview" prose is the MDX BODY (rendered via `render()`); everything the
 * detail page lays out in fixed slots — the spec table, the feature list, the challenge/solution
 * pair — is structured frontmatter so it can be validated and rendered without parsing prose.
 * `status` drives the retro card badge; `order` sorts the listing (see @components/Sections/Project).
 */
const projectsCollection = defineCollection({
  loader: glob({ pattern: "**/[^_]*{md,mdx}", base: "./src/data/projects" }),
  schema: ({ image }) =>
    z.object({
      title: z.string(), // detail H1 + SEO title + fallback card title
      cardTitle: z.string().optional(), // listing card title (the mock's differs from the H1)
      description: z.string(), // listing card excerpt + SEO meta description
      tagline: z.string(), // detail hero intro line
      status: z.enum(["complete", "in-progress"]),
      moduleId: z.string(), // shown on the detail hero, e.g. "#01_CHAT"
      order: z.number(), // listing sort key (ascending)
      thumbnail: image(),
      thumbnailAlt: z.string(),
      tech: z.array(z.string()), // flat tag pills on the card
      specs: z.array(z.object({ label: z.string(), value: z.string() })), // SYS_SPECS rows
      features: z.array(z.object({ lead: z.string(), text: z.string() })), // SYSTEM FEATURES list
      archCaption: z.string(), // ARC_MAP caption, e.g. "[Packet Switching Engine]"
      challenge: z.object({ title: z.string(), body: z.string() }),
      solution: z.object({ title: z.string(), body: z.string() }),
      draft: z.boolean().optional(),
    }),
});

const authorsCollection = defineCollection({
  loader: glob({ pattern: "**/[^_]*{md,mdx}", base: "./src/data/authors" }),
  schema: ({ image }) =>
    z.object({
      name: z.string(),
      avatar: image().optional(),
      about: z.string(),
      email: z.string(),
      authorLink: z.string(),
    }),
});

export const collections = {
  blog: blogCollection,
  authors: authorsCollection,
  projects: projectsCollection,
};
