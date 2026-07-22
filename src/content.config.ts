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
};
