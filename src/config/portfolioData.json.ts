import { type PortfolioDataProps } from "./types/configDataTypes";

// Buyer-facing portfolio copy + values — the facts you're expected to make your own: identity,
// biography, the experience/stat numbers, the home intro, and the contact prompt. Presentational
// labels (SYS_SPECS captions, "Role:" / "Yrs:", scoreboard colours) stay in their components; this
// file holds only what a buyer edits. The voice is first-person singular throughout (one developer's
// portfolio) — keep it consistent if you rewrite.
const portfolioData = {
  profile: {
    tagline: "Sergio Parra",
    heading: "Estudiante de Ingeniería de Sistemas en la Universidad El Bosque",
    role: "Systems Engineering Student",
    years: "03",
    bio: [
      "Soy estudiante de Ingeniería de Sistemas en la Universidad El Bosque, con interés en el desarrollo de software y la construcción de soluciones tecnológicas.",
      "Actualmente estoy fortaleciendo mis conocimientos en programación, bases de datos, estructuras de datos e infraestructura TI, mientras desarrollo proyectos para aplicar lo aprendido.",
    ],
    shortBio:
      "Estudiante de Ingeniería de Sistemas enfocado en aprender, construir proyectos y convertir conocimientos de programación en soluciones funcionales.",
    meta: {
      location: "Bogotá, Colombia",
      role: "Estudiante Ingenieria De Sistemas",
      favorite: "Programacion En Java",
    },
    skills: [
      { label: "Java", pct: 80 },
      { label: "JavaScript", pct: 60 },
    ],
    // The Tech Stack list — one technology per row, each with its level. Rendered by the About
    // asides (the home section + /about/), which read this ONE definition so the two can't drift.
    techStack: [
      { label: "Java / POO", level: "Avanzado" },
      { label: "Angular", level: "Intermedio" },
      { label: "HTML", level: "Intermedio" },
      { label: "CSS", level: "Intermedio" },
      { label: "JavaScript", level: "Intermedio" },
      { label: "TypeScript", level: "Intermedio" },
      { label: "SQL / BD Relacionales", level: "Intermedio" },
      { label: "Spring Boot", level: "Intermedio" },
      { label: "Astro", level: "Aprendiz" },
      { label: "Infraestructura TI", level: "Intermedio" },
    ],
  },

  stats: {
    home: ["Estudiante: Ingenieria De Sistemas", "Semestre: 04", "Proyectos: 5+"],
    profile: [
      "Class: Estudiante Ingenieria De Sistemas",
      "Lvl: Intermedio",
      "Focus: Software",
      "GitHub: P2X4A",
    ],
  },

  home: {
    tagline: "Player 1",
    heading: "Bienvenido a mi portafolio",
    intro:
      "Soy Sergio Parra, estudiante de Ingeniería de Sistemas. Este espacio reúne mis proyectos, conocimientos y experiencias mientras avanzo en mi formación como desarrollador.",
  },
} satisfies PortfolioDataProps;

export default portfolioData;
