import { glob } from "astro/loaders";
import { z } from "astro/zod";
import { defineCollection } from "astro:content";

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
      category: z.enum(["modelado", "normalizacion", "sql", "proyecto"]),
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

export const collections = {
  projects: projectsCollection,
};
