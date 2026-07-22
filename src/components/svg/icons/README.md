# Icons — `<Icon />`

24×24 icons from two Figma Community files, one component, one typed registry, zero new
dependencies. The bulk are **Stratis UI Icons** line icons — _General_, _Arrows_ (partial),
_Media & Devices_, _Alerts_, _Security_, _Images_, _Files_, _Charts_, _Development_,
_Communication_, _Editor_ (still to import: Arrows columns 4–5, _Finance_, any remaining
frames). On top is a **Social/brand** set from _Social Media Icons 24x24_ — filled marks:
`facebook`, `instagram`, `tiktok`, `threads`, `messenger`, `whatsapp`, `telegram`, `behance`,
`github`, `discord`, `linkedin`, `slack`, `line`, `apple`, `google`, `pinterest`, `google-play`,
`bluesky` (the file's `youtube` is dropped — the UI set already owns that name).

```astro
---
import { Icon } from "@components/svg/icons";
---

<Icon name="activity" />
<Icon name="trash-01" size="lg" class="text-error" />
<Icon name="search-01" title="Search" />
<!-- accessible name -->
```

- **`name`** — a typed `IconName`; illegal names fail `astro check`. Autocomplete lists every icon.
- **`size`** — `sm` `md` `lg` `xl` (`size-4…size-8`, default `md`). Or just pass `class="size-6"`.
- **color** — geometry is `currentColor`; recolor with any `text-*` token (`text-primary`,
  `text-muted-foreground`, …). Dark mode is free. Brand marks are filled silhouettes (the
  negative space, e.g. Facebook's "f", is a path knockout), so they flip with the theme too —
  they render in one tone, not brand colors.
- **a11y** — decorative by default (`aria-hidden`). Pass `title` to expose an accessible name
  (`role="img"` + `<title>`).

Follows the [primitive contract](../../ui/README.md): `data-slot="icon"`, exported `tv()` config
(`icon`), native `svg` props + variant props, merged `class`, tokens only.

## Contents

`icons.ts` is **auto-generated** — `ICONS` maps each name to the inner SVG markup, plus the
`IconName` union and an `iconNames` array (handy for galleries). Don't hand-edit it.

> `ponytail:` the whole registry is one module (~450 KB at 571 icons). It stays build-time —
> icons inline into HTML and nothing lands in client JS — but every icon markup loads even if a
> page uses one. Ceiling/upgrade path: importing it in a client `<script>` would ship it all;
> at that point split to per-file `.svg` imports (Astro native SVG components) or an SVG sprite.

## Regenerate / add more icons

Each category is one frame of the 1000-icon file. To re-pull one, or add another category frame:

1. Call the Figma MCP `get_design_context` on the category **frame** node — one call per frame
   is enough (per-column pulls are the fallback if a frame response is too large). The response
   is React reference code: a `const imgX = "<asset url>"` table plus one function per icon
   carrying `data-node-id` / `data-name` and its `src={imgX}` (occasionally the `<img>` nests
   one wrapper `<div>` deeper — match both shapes).
2. Collect `{ "id", "name", "url" }` into `manifest.json` (cache and dedupe by **node id** —
   `data-name`s are not unique in the source).
3. `node generate.mjs` — it downloads each SVG, normalizes color to `currentColor`, flattens
   bare `<g>` wrappers, strips ids, scale-to-fits the few off-grid viewBoxes, dedupes by cleaned
   content against the registry, and rewrites `icons.ts`. The generator and its `clean.mjs`
   cleaner (with self-check) live in the scratchpad used to build this set.

The cleaner asserts on anything unexpected (a `<g transform>`, a color it couldn't normalize, an
empty icon), so a bad export fails loudly instead of shipping a broken glyph.

**Brand marks** live in a different Figma file and export differently: each is filled (not
stroked) and wrapped in a `<defs><clipPath>` 24×24 frame. Run those with `BRAND=1` (the generator
passes `{ brand: true }` to the cleaner, which asserts the clip really is just the frame, then
strips the `<defs>`/`clip-path`). Their `data-name`s are `Social/<Brand>/Black`, so the manifest
carries the plain slug; the file's own labels are unreliable (`Social Icons` is LinkedIn,
`Telegram (Only sign)` is Telegram). The generator run was:
`MANIFEST=social-manifest.json CACHE=social-raw BRAND=1 node generate.mjs`.

Review the generator's report before committing: the Stratis file mislabels some glyphs —
duplicate `data-name`s on `-01`/`-02` variants, a checkmark labeled `message-square-plus`,
icons named `Component` or `-`. Fix those with a node-id-keyed name override in the generator,
never by hand-editing `icons.ts`. A cross-file name clash (the brand file's `youtube` vs the UI
set's) is reported as a collision and skipped, not overwritten — rename in the manifest if you
want to keep both.

> Heads-up: `get_design_context` counts against a per-account Figma MCP tool-call quota (the
> Starter plan caps it and paywalls further calls — frame-level pulls covered 9 categories in
> ~10 calls). Pull a few frames at a time and re-run the generator each batch (it merges
> idempotently: identical glyphs dedupe by content, so re-imports never double-add).
