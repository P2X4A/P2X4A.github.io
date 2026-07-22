# Astro Boiler

A lean **Astro 7 + Tailwind CSS v4 + TypeScript (strict)** skeleton with a CSS-first token
architecture, typed config-driven content, and an in-house UI, motion, icon and SEO stack that adds
**no runtime dependencies** beyond Astro and Tailwind themselves.

It is single-language and fully static. This is the skeleton you copy and grow into a real
template — add the components, content and search each project needs.

## Quick start

```sh
pnpm install
pnpm dev          # http://localhost:4321
```

It runs with no configuration, no API keys and no accounts. Fill in `src/config/` and your content,
then work through [Before you deploy](#before-you-deploy).

## Commands

| Command        | Action                                      |
| :------------- | :------------------------------------------ |
| `pnpm install` | Install dependencies                        |
| `pnpm dev`     | Dev server at `localhost:4321`              |
| `pnpm build`   | Production build to `dist/`                 |
| `pnpm preview` | Preview the production build                |
| `pnpm check`   | Type-check `.astro` / `.ts` (`astro check`) |
| `pnpm lint`    | ESLint                                      |
| `pnpm format`  | `eslint --fix`, then Prettier               |
| `pnpm test`    | Every `*.test.ts` self-check under `src/`   |

## Routes

| Route                  | Source                                     | Built from                 |
| :--------------------- | :----------------------------------------- | :------------------------- |
| `/`                    | `pages/index.astro`                        | `Sections/Home/Hero.astro` |
| `/privacy/`, `/terms/` | `pages/privacy.astro`, `pages/terms.astro` | `config/legalData.json.ts` |
| `/404`                 | `pages/404.astro`                          | `Sections/NotFound/*`      |
| `/examples/ui`         | `pages/examples/[catalog].astro`           | `Sections/UiCatalog/*`     |

Generated endpoints: `/robots.txt`, `/llms.txt`, `/sitemap-index.xml`. All three derive their
absolute URLs from `site`, so setting that once fixes them together.

Browse every UI primitive at **`/examples/ui`** — a dev-only catalog that is `noindex`, excluded
from the sitemap, and emits no paths in a production build.

**There is no `/blog/` route, deliberately.** The `blog` and `authors` collections are defined and
`@astrojs/mdx` is wired, so the content layer is ready — but every project wants its blog shaped
differently, and building one here would bake in a reading-time, RSS and related-posts stack that
most forks would rewrite. It is the first thing most projects add, and the collections below are
where it starts.

## Content

Collections are defined in `src/content.config.ts` (Zod), so bad frontmatter fails the build with
the entry named. Entries live one folder deep, and the folder name is the slug.

| Collection | Location            | Holds                                                                            |
| :--------- | :------------------ | :------------------------------------------------------------------------------- |
| `blog`     | `src/data/blog/`    | Posts: `title`, `description`, `authors[]`, `pubDate`, and optional `heroImage`, `updatedDate`, `categories`, `draft` |
| `authors`  | `src/data/authors/` | Bylines, referenced by posts                                                      |

Both ship empty. Add a folder with an `index.md`/`index.mdx` to create an entry.

## Configuration

Typed data lives in `src/config/`, never as literals in components:

- **`siteData.json.ts`** — brand name, title, description, the author block, `sameAs` (social URLs,
  which disambiguate the JSON-LD `Organization`) and the default social image.
- **`siteSettings.json.ts`** — `siteLang` / `siteLocale`, plus the feature switches
  `useViewTransitions` and `useAnimations`.
- **`legalData.json.ts`** — the terms and privacy copy, section by section.

Theme tokens are CSS-first in `src/styles/tailwind-theme.css`: palette aliases (`--color-primary-*`,
`--color-base-*`) feed semantic runtime vars, which feed the utilities. Rebrand by editing the alias
block — markup only ever uses `bg-primary` / `text-foreground` / `text-base-700`, so light and dark
follow automatically.

## What's in the box

- **38 UI primitives** (`src/components/ui/`) — button, dialog, dropdown, mega-menu, combobox, tabs,
  table, and the rest — each a folder with a `tailwind-variants` recipe, built on the token layer and
  zero-JS unless interaction demands otherwise. Contract: `src/components/ui/README.md`.
- **571 inlined SVG icons** (`src/components/svg/icons/`) behind a typed `<Icon name="…" />`.
  Build-time only: icons inline into HTML and nothing lands in client JS.
- **87 motion utilities** (`src/styles/motion/`) — a dependency-free port of tailwind-animations plus
  scroll-driven extensions, with a global `prefers-reduced-motion` guard.
- **An owned SEO layer** — every meta/OG tag emitted natively by `BaseHead`, JSON-LD built by typed
  helpers in `@js/schema`, and dynamic `robots.txt` / `llms.txt`. No SEO package.

## Structure

```text
src/
├── components/
│   ├── Sections/<Page>/   layout-free page sections (Global/ for cross-page ones, when one appears)
│   ├── Cards/             content-aware card compositions
│   ├── ui/<name>/         the primitive library (see its README for the contract)
│   └── svg/icons/         the <Icon> system
├── config/                typed site config — the source of truth, never literals in components
├── data/<collection>/     content collections, Zod-validated
├── js/                    TypeScript utilities (textUtils, schema) + their *.test.ts checks
├── layouts/               BaseLayout + BaseHead (all meta/SEO tags live here)
├── pages/                 file routes — thin shells owning BaseLayout + SEO
└── styles/                global.css entry, tailwind-theme.css tokens, motion/ catalog
```

Pages are thin route shells that own `BaseLayout` + SEO and compose **Sections**; Sections build on
**ui** primitives and **Cards**. The three contracts are `Sections/README.md`, `Cards/README.md` and
`ui/README.md`.

## Before you deploy

1. **`SITE_URL`** — your production domain, set in your host's environment variables. It feeds
   canonical, OG, JSON-LD, the sitemap, `robots.txt` and `llms.txt`. A **production** deploy fails if
   it is missing or still `example.com`, so the placeholder cannot reach a live site; local builds
   and deploy previews are unaffected. See `.env.example`.
2. **`public/og.jpg`** — replace the placeholder with a real 1200×630 social image.
3. **`src/config/siteData.json.ts`** — name, author, and the `sameAs` list.
4. **`src/config/legalData.json.ts`** — the terms and privacy copy are placeholders. Have them
   reviewed; they are not legal advice.
5. **Favicons** — `public/favicon.svg` and `public/favicon.ico`.
6. **Delete the dev catalog** — `src/components/Sections/UiCatalog/` and `src/pages/examples/`, once
   you no longer need the showroom. It builds no pages in production, but Tailwind still scans its
   markup, so its demo classes sit in the stylesheet every page loads: removing it takes the shared
   CSS from 76,413 to 56,695 bytes (−25.8%) and drops 70 unused `@keyframes`. Keep it while you are
   still picking primitives — the cost is CSS, not JS, and it is the fastest way to see all 38.

## Verifying a change

```sh
pnpm lint && pnpm check && pnpm build && pnpm test
```

The build is the real check: content-schema and config mistakes surface there. `pnpm test` runs every
`*.test.ts` under `src/` with Node's type stripping — no framework, no fixtures — and **fails if it
finds none**, so a check cannot go missing unnoticed.

## Docs

House rules live in the project docs — TypeScript,
Tailwind, Astro, motion, SEO. `wiki/` is a maintained knowledge base covering every subsystem, and
records the removal of the former i18n layer and Keystatic CMS along with the shape to restore if a
project needs them back — start at `wiki/index.md`.
