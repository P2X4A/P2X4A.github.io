# Cards — composed card components

A **card** here is a content-aware composition (BlogCard, PricingCard, TeamCard, …) built from the
`ui/card` primitives (`Card`, `CardImage`, `CardHeader`, `CardTitle`, `CardDescription`,
`CardContent`, `CardFooter`, `CardAction`). The primitive stays generic in `src/components/ui/card/`;
what lands in this folder knows about a data shape (a `CollectionEntry<"blog">`, a pricing tier)
and is what sections map over.

```
src/components/Cards/
└── <Name>Card.astro   # PascalCase, one file per card; typed props for its data shape
```

Empty on purpose (YAGNI) — the folder exists so the first card added to a project has one obvious
home instead of being inlined into a section.
