# Portafolio — Sergio Parra

Portafolio personal de **Sergio Parra**, estudiante de Ingeniería de Sistemas en la Universidad El Bosque (Bogotá, Colombia).

Sitio con estética retro 8-bit / pixel-art donde presento mi perfil, proyectos, evidencias académicas, blog y contacto.

🌐 **Demo:** https://p2x4a.github.io

## Secciones

- **Inicio:** presentación, stats, proyectos destacados y últimas publicaciones.
- **Presentación (`/about/`):** perfil, habilidades, logros y herramientas.
- **Evidencias (`/projects/`):** proyectos y trabajos académicos, incluyendo *University Championship* (modelo Entidad-Relación).
- **Blog (`/blog/`):** artículos y notas.
- **Contacto (`/contact/`):** formulario con envío por Resend.

## Tecnologías

- [Astro 7](https://astro.build) + TypeScript (strict)
- [Tailwind CSS v4](https://tailwindcss.com)
- MDX + Content Collections (Zod)
- Deploy: GitHub Pages (build estático) / Cloudflare Workers para `/contact/`

## Uso local

Requisitos: Node `>=22.13.0` y `pnpm`.

```sh
pnpm install
pnpm dev      # http://localhost:4321
pnpm build    # build de producción en dist/
pnpm check    # type-check
pnpm test     # tests en src/**/*.test.ts
```

## Estructura

```text
src/
  pages/       # rutas: index, about, projects, blog, contact, privacy, terms, 404
  components/Sections/  # secciones por página + Global (Header/Footer)
  components/ui/        # primitivas UI
  config/      # siteData, portfolioData, navData, socialData
  data/        # blog/, projects/, authors/
  layouts/     # BaseLayout + BaseHead (SEO)
  styles/      # tokens Tailwind + motion
  actions/     # acción de contacto (Resend)
public/        # favicon, og.jpg
```

## Contacto

- Email: sparrar@unbosque.edu.co
- GitHub: https://github.com/P2X4A

## Licencia

Ver `LICENSE`. Material de terceros (fuentes, iconos, imágenes demo) en `THIRD-PARTY.md`.
