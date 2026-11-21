# Portafolio de Sergio Parra

Portafolio personal de Sergio Parra, estudiante de Ingeniería de Sistemas en la Universidad El Bosque (Bogotá, Colombia). Reúne mi perfil y los trabajos de Bases de Datos: modelado, normalización, álgebra relacional, SQL y el proyecto final en equipo. El sitio tiene una estética retro de 8 bits.

Sitio publicado: https://p2x4a.github.io

## Páginas

- Inicio: presentación, cifras, tecnologías y proyectos recientes.
- Presentación (`/about/`): perfil, habilidades, herramientas, logros y el video de presentación de Bases de Datos 1.
- Evidencias (`/projects/`): una ficha por trabajo, en cinco secciones: Modelado, Normalización, Álgebra relacional, SQL y Proyecto.
- Contacto (`/contact/`): formulario que valida en el navegador y abre un correo prellenado.
- Privacidad y términos (`/privacy/` y `/terms/`).

## Tecnologías

- [Astro 7](https://astro.build) con TypeScript estricto
- [Tailwind CSS v4](https://tailwindcss.com)
- MDX y colecciones de contenido validadas con Zod
- GitHub Pages: el sitio es estático y se despliega al hacer push a `main`, con `.github/workflows/deploy.yml`

## Uso local

Requisitos: Node `>=22.13.0` y `pnpm`.

```sh
pnpm install
pnpm dev      # http://localhost:4321
pnpm build    # sitio estático en dist/
pnpm check    # tipos
pnpm lint     # ESLint
pnpm test     # pruebas en src/**/*.test.ts
```

## Estructura

```text
src/
  pages/       # rutas: index, about, projects, contact, privacy, terms, 404
  components/  # Sections (por página y Global), ui (primitivas) y svg (iconos)
  config/      # siteData, portfolioData, navData, socialData
  data/        # projects/: una carpeta con index.mdx por trabajo
  js/          # funciones puras y sus pruebas
  layouts/     # BaseLayout y BaseHead (SEO)
  styles/      # tokens de Tailwind y animaciones
public/        # favicon, og.jpg y las evidencias descargables
```

## Contacto

- Correo: sparrar@unbosque.edu.co
- GitHub: https://github.com/P2X4A

Como el sitio es estático, el formulario no envía nada a un servidor: valida con el esquema Zod de `src/js/contact.ts` y abre el cliente de correo (`mailto:`). El destino se cambia en `src/config/siteData.json.ts` (`author.email`).

## Licencia

Ver `LICENSE`. El material de terceros (fuentes, iconos, imágenes de ejemplo) está en `THIRD-PARTY.md`.
