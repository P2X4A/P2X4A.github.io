// Categorías de la sección Evidencias (/projects/).
// Una definición por categoría: slug de URL, etiqueta, tagline e intro.
// Las 4 subpáginas (/projects/<slug>/) y el índice comparten este registro
// para que etiquetas y rutas no se dupliquen en cada página.

export const projectCategories = [
  {
    slug: "modelado",
    label: "Modelado",
    tagline: "Modelo E-R",
    intro:
      "Diagramas Entidad-Relación: entidades, atributos y relaciones del torneo universitario.",
  },
  {
    slug: "normalizacion",
    label: "Normalización",
    tagline: "1FN · 2FN · 3FN",
    intro:
      "Proceso de normalización: de la tabla sin normalizar hasta la tercera forma normal.",
  },
  {
    slug: "sql",
    label: "SQL",
    tagline: "Álgebra · Consultas",
    intro:
      "Consultas sobre esquemas reales: álgebra relacional extendida y su traducción a SQL.",
  },
  {
    slug: "proyecto",
    label: "Proyecto",
    tagline: "Entrega Final",
    intro: "Proyecto integrador de Bases de Datos 1: modelo, normalización y SQL aplicados.",
  },
] as const;

export type ProjectCategorySlug = (typeof projectCategories)[number]["slug"];
