# 8-BitQuest

A **retro 8-bit, pixel-art developer-portfolio theme** built on **Astro 7 + Tailwind CSS v4 +
TypeScript (strict)**, with a CSS-first token architecture, typed config-driven content, and an
in-house UI, motion, icon and SEO stack. Headings are Press Start 2P on a black-bordered "pixel
panel" surface; every colour flows through a semantic token layer, so the committed light and dark
themes flip for free.

It ships as a **working site, not an empty skeleton** — a Home, About, Blog, Projects and a
server-rendered Contact page, six sample posts and six sample projects, all reproduced from the
source Figma. The one non-static route is `/contact/`, which posts to a Resend-backed Astro action.

## Quick start

```sh
pnpm install
pnpm dev          # http://localhost:4321
```

It runs with no configuration and no keys — the contact form just reports "not configured yet" until
you add its Resend keys (see [Contact form](#contact-form)). Fill in `src/config/`, swap the sample
content for your own, then work through [Before you deploy](#before-you-deploy).

## Commands

| Command        | Action                                              |
| :------------- | :-------------------------------------------------- |
| `pnpm install` | Install dependencies                                |
| `pnpm dev`     | Dev server at `localhost:4321`                      |
| `pnpm build`   | Production build to `dist/` (`client/` + `server/`) |
| `pnpm preview` | Preview the production build                        |
| `pnpm start`   | Run the built Node server (`dist/server/entry.mjs`) |
| `pnpm check`   | Type-check `.astro` / `.ts` (`astro check`)         |
| `pnpm lint`    | ESLint                                              |
| `pnpm format`  | `eslint --fix`, then Prettier                       |
| `pnpm test`    | Every `*.test.ts` self-check under `src/`           |

## Routes

| Route                  | Source                               | Built from                             |
| :--------------------- | :----------------------------------- | :------------------------------------- |
| `/`                    | `pages/index.astro`                  | `Sections/Home/*`                      |
| `/about/`              | `pages/about.astro`                  | `Sections/About/*`                     |
| `/blog/`               | `pages/blog/index.astro`             | `Sections/Blog/*` (listing)            |
| `/blog/<slug>/`        | `pages/blog/[slug].astro`            | `Sections/Blog/BlogArticle` (per post) |
| `/projects/`           | `pages/projects/index.astro`         | `Sections/Project/*` (listing)         |
| `/projects/<slug>/`    | `pages/projects/[slug].astro`        | `Sections/Project/ProjectArticle`      |
| `/contact/`            | `pages/contact.astro` (**SSR**)      | `Sections/Contact/*` + a Resend action |
| `/privacy/`, `/terms/` | `pages/privacy.astro`, `terms.astro` | `config/legalData.json.ts`             |
| `/404`                 | `pages/404.astro`                    | `Sections/NotFound/*`                  |
| `/examples/ui`         | `pages/examples/[catalog].astro`     | `Sections/UiCatalog/*` (dev-only)      |

Every route prerenders to static HTML **except `/contact/`**, which sets `export const prerender =
false` so it can take the form POST and re-render with the result. `/examples/ui` is a `noindex`
dev-only catalog: it is excluded from the sitemap and emits no HTML in a production build.

Generated endpoints: `/robots.txt`, `/llms.txt`, `/rss.xml`, `/sitemap-index.xml`. The first three
are hand-owned dynamic routes whose absolute URLs derive from `site`, so setting that once fixes them
together.

## Content

Collections are defined in `src/content.config.ts` (Zod), so bad frontmatter fails the build with the
entry named. Entries live one folder deep and the folder name is the slug.

| Collection | Location             | Ships with     | Holds                                                                                                                                           |
| :--------- | :------------------- | :------------- | :---------------------------------------------------------------------------------------------------------------------------------------------- |
| `blog`     | `src/data/blog/`     | **6 posts**    | `title`, `description`, `authors[]` (≥1), `pubDate`, `heroImage(+alt)`, `category`, `tags`, optional `updatedDate`, `draft`                     |
| `projects` | `src/data/projects/` | **6 projects** | `title`, `description`, `tagline`, `status`, `moduleId`, `order`, `thumbnail(+alt)`, `tech[]`, `specs[]`, `features[]`, `challenge`, `solution` |
| `authors`  | `src/data/authors/`  | `admin`        | `name`, `authorLink`, optional `avatar` — referenced by posts as the byline                                                                     |

The samples are retro-flavoured placeholders; replace them with your own. A blog post's body is
free-form MDX (rendered through `.blog-prose`); a project's overview is MDX while its spec/feature
data is structured frontmatter.

## Configuration

Typed data lives in `src/config/`, never as literals in components:

- **`siteData.json.ts`** — brand name, title, description, the author block, `sameAs` (social URLs
  that disambiguate the JSON-LD `Organization`) and the default social image.
- **`siteSettings.json.ts`** — `siteLang` / `siteLocale`, plus the feature switches
  `useViewTransitions` and `useAnimations`.
- **`legalData.json.ts`** — the terms and privacy copy, section by section.
- **`portfolioData.json.ts`** — the profile identity, biography, experience/stat values, home
  intro, and contact-facing organisation copy: the facts a buyer is expected to customise, in one
  typed place.

**Theme tokens** are CSS-first, in three layers (see `src/styles/tailwind-theme.css` +
`global.css`): palette aliases (`--color-primary-*`, `--color-base-*`) feed semantic runtime vars
(`--primary`, `--foreground`, `--outline`), which feed the utilities. Markup only ever uses
`bg-primary` / `text-foreground` / `text-base-700`, so a rebrand is one edit to the alias block and
both themes follow. The signature look — a black 4px border plus a hard offset `shadow-pixel` — is
the `ui/pixel-panel` primitive; the shadow colour is itself a theme-aware token (`--pixel-shadow`).

## What's in the box

- **39 UI primitives** (`src/components/ui/`) — button, dialog, dropdown, mega-menu, combobox, tabs,
  table, pixel-panel, theme-toggle, and the rest — each a folder with a `tailwind-variants` recipe,
  built on the token layer and zero-JS unless interaction demands it. Alongside them sit **7 internal
  entries** (`_client.ts`, `_dialog.ts`, `_listbox.ts`, `_popover.ts`, `_overlay.css`, `_field.ts`,
  `_Chevron.astro`) that the primitives share. Contract: `src/components/ui/README.md`.
- **571 inlined SVG icons** (`src/components/svg/icons/`) behind a typed `<Icon name="…" />`.
  Build-time only: icons inline into HTML and nothing lands in client JS.
- **87 motion utilities** (`src/styles/motion/`) — a dependency-free port of tailwind-animations plus
  scroll-driven extensions, with a global `prefers-reduced-motion` guard.
- **An owned SEO layer** — every meta/OG tag emitted natively by `BaseHead`, JSON-LD (Organization +
  WebSite site-wide, plus per-post `BlogPosting` + `BreadcrumbList`) built by typed helpers in
  `@js/schema`, and dynamic `robots.txt` / `llms.txt` / `rss.xml`. No SEO package.

The owned motion, icon and SEO layers add **no runtime dependencies**. The primitives use
`tailwind-variants` + `tailwind-merge`; SSR uses `@astrojs/node`; content uses `@astrojs/mdx`; the
two fonts are self-hosted via `@fontsource`.

## Contact form

`/contact/` is the one server-driven page. A native `<form method="POST">` binds to an Astro action
(`src/actions/index.ts`), so it works with JavaScript disabled: the server re-validates with
`contactSchema`, runs two spam gates (a honeypot and a submit-time gate), and sends the mail with a
plain `fetch` to the Resend API — no SDK, no dependency, a 10-second timeout. Provider errors are
logged server-side and never shown to the visitor.

It needs two environment variables (read at **request** time, so a missing key never breaks the
build — the form just says "not configured yet"):

| Variable             | Required | Purpose                                                           |
| :------------------- | :------: | :---------------------------------------------------------------- |
| `RESEND_API_KEY`     |   yes    | Resend API key                                                    |
| `CONTACT_TO_EMAIL`   |   yes    | Where submissions are delivered (your inbox)                      |
| `CONTACT_FROM_EMAIL` |    no    | From address; defaults to Resend's shared `onboarding@resend.dev` |

The default sender only delivers to your own Resend account address. **To send anywhere else you must
verify a domain in Resend** and set `CONTACT_FROM_EMAIL` to an address on it. See `.env.example`.

## Structure

```text
src/
├── components/
│   ├── Sections/<Page>/   layout-free page sections (Global/ for cross-page chrome: Header, Footer)
│   ├── Cards/             content-aware card compositions (built on ui/card)
│   ├── ui/<name>/         the primitive library (see its README for the contract)
│   └── svg/icons/         the <Icon> system
├── actions/               the contact server action (Resend)
├── config/                typed site config — the source of truth, never literals in components
├── data/<collection>/     content collections, Zod-validated
├── js/                    TypeScript utilities (schema, contact, readingTime, nav…) + their *.test.ts
├── layouts/               BaseLayout + BaseHead (all meta/SEO tags live here)
├── pages/                 file routes — thin shells owning BaseLayout + SEO
└── styles/                global.css entry, tailwind-theme.css tokens, motion/ catalog
```

Pages are thin route shells that own `BaseLayout` + SEO and compose **Sections**; Sections build on
**ui** primitives and **Cards**. The three contracts are `Sections/README.md`, `Cards/README.md` and
`ui/README.md`.

## Deployment

The build is static **except `/contact/`**, so `@astrojs/node` (standalone) is mounted and the output
splits: prerendered pages land in `dist/client/`, the one server entry in `dist/server/entry.mjs`.

```sh
pnpm build
pnpm start        # node ./dist/server/entry.mjs  (honours HOST / PORT; default :4321)
```

This suits a Docker / Traefik / Dokploy target. **To change hosts**, swap the adapter in
`astro.config.mjs` for `@astrojs/netlify` or `@astrojs/vercel` (a two-line change; nothing else knows
which adapter is mounted). **To go fully static**, remove the contact form (or its `prerender = false`)
and drop the adapter — then any static host serves `dist/`.

Required environment variables: **`SITE_URL`** (your production domain — feeds canonical, OG, JSON-LD,
sitemap, `robots.txt`, `llms.txt`; a production deploy throws on the `example.com` placeholder), plus
the contact keys above. See `.env.example`.

## Before you deploy

1. **`SITE_URL`** — your production domain, in the host's environment variables. A **production**
   deploy fails if it is missing or still `example.com`; local builds and deploy previews are
   unaffected.
2. **Contact keys** — `RESEND_API_KEY` and `CONTACT_TO_EMAIL` (and, to send beyond your own inbox, a
   verified domain + `CONTACT_FROM_EMAIL`).
3. **`public/og.jpg`** — replace the placeholder with a real 1200×630 social image.
4. **`src/config/*`** — `siteData`, `portfolioData`, and the `legalData` terms/privacy copy (the last
   is placeholder text, not legal advice — have it reviewed).
5. **Favicons** — `public/favicon.svg` and `public/favicon.ico`.
6. **Delete the dev catalog** — `src/components/Sections/UiCatalog/` and `src/pages/examples/`, once
   you have finished picking primitives. It builds no pages in production, but Tailwind still scans its
   markup, so its demo classes sit in the stylesheet every page loads; removing it trims the shared CSS
   by roughly a quarter (measured 76.4 KB → 56.7 KB on the stock catalog) and drops ~70 unused
   `@keyframes`.

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
