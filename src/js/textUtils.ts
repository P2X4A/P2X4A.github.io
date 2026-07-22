import { siteLocale } from "@/config/siteSettings.json";

/**
 * * returns a "slugified" version of the text
 * @param text: text to slugify
 */
export function slugify(text: string): string {
  return text
    .toString()
    .toLowerCase()
    .replace(/\s+/g, "-") // spaces -> dashes
    .replace(/[^\w-]+/g, "") // strip non-word chars
    .replace(/--+/g, "-") // collapse multiple dashes
    .replace(/^-+/, "") // trim leading dash
    .replace(/-+$/, ""); // trim trailing dash
}

/**
 * * returns a "humanized" version of the text — slugify, then spaces + Title Case
 * @param text: text to humanize
 */
export function humanize(text: string): string {
  return slugify(text)
    .replace(/-/g, " ")
    .replace(/\w\S*/g, (w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase());
}

/**
 * * returns a formatted date string in the site's locale (siteLocale in siteSettings)
 * @param date: date to format
 */
export function formatDate(date: string | number | Date): string {
  return new Date(date).toLocaleDateString(siteLocale, {
    timeZone: "UTC",
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}
