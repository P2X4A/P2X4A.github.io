# Content collections

Schemas live in `src/content.config.ts`. There is ONE collection, and it nests one folder deep so an
entry can keep its images beside it:

```
src/data/
└── projects/<slug>/index.mdx   # entry id => "<slug>"
```

## Replacing the demo content

The projects are placeholders — delete them and add your own. One thing to know, verified:

**Clear the content-layer cache after deleting entries.** Astro's content layer keeps a persistent
store at `node_modules/.astro/data-store.json`, and it survives `rm -rf .astro`. If you delete an
entry without clearing it, the next build still tries to render the deleted route and fails with
`UnknownContentCollectionError: Unexpected error while rendering → <slug>` — naming a file you
already removed, which is a confusing place to land. Fix:

```sh
rm -rf node_modules/.astro .astro dist && pnpm build
```

With the collection emptied, the build succeeds and `/projects/` renders `CardGrid`'s empty state;
you will see a `The collection "projects" does not exist or is empty` warning, which is expected
until you add an entry.

## The blog

The site had a blog (a `blog` collection + an `authors` collection, its own routes, RSS feed and
`.blog-prose` styles). It was removed for now — the posts were template demo content, and the
portfolio's real content lives in `projects`. If you want it back, the removed pieces are in the
git history: the `blog`/`authors` collections in `src/content.config.ts`, `src/pages/blog/*`,
`src/pages/rss.xml.ts`, `src/components/Sections/Blog/*`, `@js/blogData`, `@js/postCards` and
`@js/rss`, plus the `.blog-prose` block in `src/styles/global.css`.
