# Sections — the astro-boiler section contract

A **section** is a layout-free block of page content (a hero, a feature grid, a legal article).
Pages stay thin route shells: `src/pages/*` owns `BaseLayout` + SEO (title, description, noindex,
schema) and composes sections; a section never imports `BaseLayout`.

## Layout

```
src/components/Sections/
├── Global/          # sections shared across pages (Header, Footer, CTA banner, …) — not yet created
└── <Page>/          # sections of one page: Home/, Legal/, NotFound/, UiCatalog/, …
    └── <Name>.astro # PascalCase, one file per section
```

- **Global vs page-specific**: a section used by 2+ pages moves to `Global/`; until then it lives
  under its page's folder. **`Global/` does not exist yet** — create it with the first shared
  section rather than leaving an empty box (`wiki/ideal-template/architecture.md`: don't pre-create
  empties). Sub-parts of a section (e.g. `NotFoundIllustration`) sit as sibling
  files in the same folder and are imported relatively (`./NotFoundIllustration.astro`).
- **Data flows in from the route.** A section either receives its content as typed props (see
  `Legal/LegalArticle.astro`) or reads config/i18n itself via the `@js` helpers — never both for
  the same data.
- **Build sections from the primitives** in `@components/ui/*` and `@components/Cards/*`; tokens
  only, no raw colors (see the project docs).
