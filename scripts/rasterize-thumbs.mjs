// Rasterize the hand-drawn SVG thumbnails (src/assets/evidencias/<slug>/thumbnail.svg) into the PNGs
// the site actually serves.
//
// WHY: the project's `thumbnail` frontmatter feeds BOTH the listing card AND the page's og:image
// (see BaseHead.astro). Social platforms don't render SVG, so an SVG thumbnail would ship a broken
// preview. Astro's `image()` needs a raster file it can measure, so the PNG is what gets referenced
// and the SVG stays as the editable source.
//
// Run after editing an SVG:  node scripts/rasterize-thumbs.mjs
import { readdir } from "node:fs/promises";
import { join } from "node:path";

import sharp from "sharp";

const EVIDENCIAS = "src/assets/evidencias";

/** Every `thumbnail.svg` under the evidence folders, paired with its PNG target. */
async function findSources(dir) {
  const found = [];
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const path = join(dir, entry.name);
    if (entry.isDirectory()) {
      found.push(...(await findSources(path)));
    } else if (entry.name === "thumbnail.svg") {
      found.push([path, path.replace(/\.svg$/, ".png")]);
    }
  }
  return found;
}

const pairs = await findSources(EVIDENCIAS);
if (pairs.length === 0) {
  console.log("no hay SVG que rasterizar");
} else {
  for (const [src, out] of pairs) {
    const info = await sharp(src, { density: 288 })
      .resize(960, 540, { fit: "contain", background: "#0d0d26" })
      .png()
      .toFile(out);
    console.log(`OK ${out} — ${info.width}x${info.height}, ${Math.round(info.size / 1024)}KB`);
  }
}
