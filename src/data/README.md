# Content collections

Schemas live in `src/content.config.ts`. Entries sit directly under their collection dir:

```
src/data/
├── blog/<slug>/index.md        # entry id => "<slug>"
└── authors/<name>/index.md
```

Format post dates with `formatDate(date)` from `@js/textUtils`.

If you re-add i18n, nest per-locale folders (`blog/<locale>/<slug>/` → id `"<locale>/<slug>"`)
and restore a language filter — the removed helpers are in git history.
