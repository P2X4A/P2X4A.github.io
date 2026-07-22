/**
 * * Types for the typed config data files in src/config/.
 * Add interfaces here as you add data files (faq, testimonials, team, …).
 */

// --------------------------------------------------------
// site data (meta / branding)
export interface SiteDataProps {
  name: string;
  title: string;
  description: string;
  // used for blog post / article metadata
  author: {
    name: string;
    email: string;
    twitter: string; // for twitter card attribution, e.g. "@handle" minus the @
  };
  // fallback social/OG image when a page has none
  defaultImage: {
    src: string;
    alt: string;
  };
  // social/profile URLs for the site's Organization JSON-LD (`sameAs`). Empty is fine.
  sameAs?: readonly string[];
}

// --------------------------------------------------------
// legal pages (terms, privacy), keyed by document
export interface LegalSection {
  heading: string;
  // each entry renders as its own <p>
  body: string[];
}

export interface LegalPageProps {
  title: string;
  description: string; // meta description (SEO)
  lastUpdated: string; // ISO date (YYYY-MM-DD); formatted at render via formatDate
  intro: string;
  sections: LegalSection[];
}

// the two documents each locale's legalData file must provide
export type LegalData = Record<"terms" | "privacy", LegalPageProps>;

// --------------------------------------------------------
// site settings
export interface SiteSettingsProps {
  useViewTransitions?: boolean;
  // master switch for the decorative motion layer (scroll-reveal via <Reveal>, etc.).
  // Independent of `prefers-reduced-motion`, which is always honored by the global guard in motion/index.css.
  useAnimations?: boolean;
}
