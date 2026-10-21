// Rasterize a hand-drawn SVG diagram into the PNG the site serves.
//
// WHY: the diagrams embedded inside a project body (the functional-dependency diagrams) are authored
// as SVG so they stay crisp to edit, but the site links PNG so they render the same everywhere and
// can be opened at full resolution. Deliberately apart from rasterize-thumbs.mjs: those are square
// card covers forced to 960x540, while a diagram keeps its own aspect ratio and is sized by width.
//
// Usage: node scripts/rasterize-diagram.mjs <source.svg> <target.png> [width]
import sharp from "sharp";

const [, , source, target, widthArg] = process.argv;

if (!source || !target) {
  console.error("uso: node scripts/rasterize-diagram.mjs <source.svg> <target.png> [width]");
  process.exit(1);
}

const width = Number(widthArg) || 1600;

const info = await sharp(source, { density: 288 })
  .resize({ width })
  .png()
  .toFile(target);

console.log(`OK ${target} — ${info.width}x${info.height}, ${Math.round(info.size / 1024)}KB`);
