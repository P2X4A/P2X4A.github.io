// Extract the text of a .docx, rendering Word's native math (OMML) as linear notation.
// WHY: the markdown converter used for these exercises flattens the equations into
// unreadable fragments, so the .docx is the only faithful source for the expressions.
//
// Usage: node scripts/docx-text.mjs <file.docx>
import { execFileSync } from "node:child_process";
import { mkdtempSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const file = process.argv[2];
if (!file) {
  console.error("uso: node scripts/docx-text.mjs <file.docx>");
  process.exit(1);
}

const dir = mkdtempSync(join(tmpdir(), "docx-"));
execFileSync("powershell", [
  "-NoProfile",
  "-Command",
  `Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('${file}', '${dir}')`,
]);

const xml = readFileSync(join(dir, "word", "document.xml"), "utf8");

/** Local name of a tag, ignoring the namespace prefix. */
const tag = (name) => name.split(":").pop();

/**
 * Render a math run / structure as linear text.
 * - m:sSub  base_{sub}      - m:sSup  base^{sup}
 * - m:sSubSup base_{sub}^{sup} - m:f   (num)/(den)
 * - m:d     (delimiters)     - m:nary operator with its limits
 * - m:func  name(argument)
 */
function math(node) {
  const children = [...node.children].filter((c) => c.type === "element");
  const name = tag(node.name);
  const parts = children.map(math);

  switch (name) {
    case "t":
      return node.text;
    case "r":
      return children.map(math).join("");
    case "sSub":
      return `${parts[0] ?? ""}_{${parts[1] ?? ""}}`;
    case "sSup":
      return `${parts[0] ?? ""}^{${parts[1] ?? ""}}`;
    case "sSubSup":
      return `${parts[0] ?? ""}_{${parts[1] ?? ""}}^{${parts[2] ?? ""}}`;
    case "f":
      return `(${parts[0] ?? ""})/(${parts[1] ?? ""})`;
    case "d":
      return `(${parts.slice(1, -1).join("")})`;
    case "nary": {
      const op = children.find((c) => tag(c.name) === "naryPr");
      const chr = op ? (op.text || "") : "";
      const limits = children.filter((c) => tag(c.name) !== "naryPr");
      const sub = limits.find((c) => tag(c.name) === "sub");
      const sup = limits.find((c) => tag(c.name) === "sup");
      const body = limits.filter((c) => tag(c.name) === "e").map(math).join("");
      const s = sub ? `_${math(sub)}` : "";
      const p = sup ? `^${math(sup)}` : "";
      return `${chr}${s}${p} ${body}`;
    }
    case "func":
      return `${parts[0] ?? ""}(${parts.slice(1).join("")})`;
    case "e":
      return parts.join("");
    case "num":
    case "den":
    case "sub":
    case "sup":
    case "oMath":
    case "oMathPara":
    case "m":
      return parts.join("");
    default:
      return parts.join("");
  }
}

/** Paragraph text: regular Word runs + any math inside. */
function paragraph(p) {
  let out = "";
  for (const node of p.children) {
    if (node.type !== "element") continue;
    const name = tag(node.name);
    if (name === "t") out += node.text;
    else if (name === "oMath" || name === "oMathPara") out += math(node);
    else if (name === "tab") out += "\t";
    else if (name === "br") out += "\n";
  }
  return out;
}

// Walk the document body: paragraphs and tables.
function walk(node, out) {
  for (const child of node.children) {
    if (child.type !== "element") continue;
    const name = tag(child.name);
    if (name === "p") {
      out.push(paragraph(child));
    } else if (name === "tbl") {
      for (const row of child.children.filter((c) => tag(c.name) === "tr")) {
        const cells = row.children
          .filter((c) => tag(c.name) === "tc")
          .map((c) => c.children.filter((x) => tag(x.name) === "p").map(paragraph).join(" ⏎ "));
        out.push(`| ${cells.join(" | ")} |`);
      }
      out.push("");
    } else {
      walk(child, out);
    }
  }
}

const out = [];
walk({ children: [...xml.matchAll(/<(\w+:\w+)([^>]*)>([\s\S]*?)<\/\1>/g)].length ? [] : [] }, out);

// The XML is a single string; parse it with a tiny walker over the raw source instead.
const body = xml.slice(xml.indexOf("<w:body"), xml.lastIndexOf("</w:body>"));
const blocks = body.split(/(?=<w:p[ >])|(?=<w:tbl[ >])/).filter((b) => b.trim());
for (const block of blocks) {
  if (block.startsWith("<w:tbl")) {
    const rows = block.split(/(?=<w:tr[ >])/).filter((r) => r.includes("<w:tc"));
    for (const row of rows) {
      const cells = row
        .split(/(?=<w:tc[ >])/)
        .filter((c) => c.includes("<w:tc"))
        .map((c) => {
          const paras = c.split(/(?=<w:p[ >])/).filter((p) => p.includes("<w:p"));
          return paras.map(paragraphFromSource).join(" ⏎ ");
        });
      out.push(`| ${cells.join(" | ")} |`);
    }
    out.push("");
  } else {
    out.push(paragraphFromSource(block));
  }
}

function paragraphFromSource(src) {
  let out = "";
  // Walk the source linearly, emitting text runs and math structures.
  const token = /<m:oMathPara[\s\S]*?<\/m:oMathPara>|<m:oMath[\s\S]*?<\/m:oMath>|<w:t(?:\s[^>]*)?>([\s\S]*?)<\/w:t>|<w:tab\s*\/>|<w:br\s*\/>/g;
  let m;
  while ((m = token.exec(src)) !== null) {
    const chunk = m[0];
    if (chunk.startsWith("<w:t")) {
      out += chunk.replace(/<[^>]+>/g, "");
    } else if (chunk.startsWith("<w:tab")) {
      out += "\t";
    } else if (chunk.startsWith("<w:br")) {
      out += "\n";
    } else {
      out += mathFromSource(chunk);
    }
  }
  return out;
}

/** Render an OMML fragment (source string) as linear notation. */
function mathFromSource(src) {
  const frag = src.replace(/<m:oMathPara[^>]*>/, "").replace(/<\/m:oMathPara>/, "");
  const body = frag.replace(/<m:oMath[^>]*>/, "").replace(/<\/m:oMath>/, "");
  let out = "";
  let pos = 0;
  while (pos < body.length) {
    const open = body.indexOf("<m:", pos);
    if (open === -1) break;
    const name = tag(body.slice(open + 3, body.indexOf(">", open)));
    const selfClosing = body[open + 3 + name.length] === "/";
    const closeTag = `</m:${name}>`;
    const close = body.indexOf(closeTag, open);
    if (close === -1) break;
    const inner = selfClosing ? "" : body.slice(open + 3 + name.length + 1, close);
    out += mathNode(name, inner);
    pos = close + closeTag.length;
  }
  return out;
}

function mathNode(name, inner) {
  const children = splitElements(inner, "m:");
  switch (name) {
    case "t":
      return inner.replace(/<[^>]+>/g, "");
    case "r":
      return children.map((c) => mathNode(c.name, c.inner)).join("");
    case "sSub": {
      const [e, sub] = children;
      return `${e ? mathNode(e.name, e.inner) : ""}_{${sub ? mathNode(sub.name, sub.inner) : ""}}`;
    }
    case "sSup": {
      const [e, sup] = children;
      return `${e ? mathNode(e.name, e.inner) : ""}^{${sup ? mathNode(sup.name, sup.inner) : ""}}`;
    }
    case "sSubSup": {
      const [e, sub, sup] = children;
      return `${e ? mathNode(e.name, e.inner) : ""}_{${sub ? mathNode(sub.name, sub.inner) : ""}}^{${sup ? mathNode(sup.name, sup.inner) : ""}}`;
    }
    case "f": {
      const [num, den] = children;
      return `(${num ? mathNode(num.name, num.inner) : ""})/(${den ? mathNode(den.name, den.inner) : ""})`;
    }
    case "d": {
      const items = children.filter((c) => c.name !== "dPr");
      const beg = /begChr="([^"]+)"/.exec(inner)?.[1] ?? "(";
      const end = /endChr="([^"]+)"/.exec(inner)?.[1] ?? ")";
      return `${beg}${items.map((c) => mathNode(c.name, c.inner)).join("")}${end}`;
    }
    case "nary": {
      const chr = /<m:chr m:val="([^"]+)"/.exec(inner)?.[1] ?? "∑";
      const sub = children.find((c) => c.name === "sub");
      const sup = children.find((c) => c.name === "sup");
      const e = children.find((c) => c.name === "e");
      return `${chr}${sub ? `_${mathNode(sub.name, sub.inner)}` : ""}${sup ? `^${mathNode(sup.name, sup.inner)}` : ""} ${e ? mathNode(e.name, e.inner) : ""}`;
    }
    case "func": {
      const nameEl = children[0];
      const args = children.slice(1);
      return `${nameEl ? mathNode(nameEl.name, nameEl.inner) : ""}(${args.map((c) => mathNode(c.name, c.inner)).join("")})`;
    }
    case "e":
      return children.map((c) => mathNode(c.name, c.inner)).join("");
    default:
      return children.map((c) => mathNode(c.name, c.inner)).join("");
  }
}

/** Split an XML fragment into its direct child elements. */
function splitElements(src, prefix) {
  const out = [];
  let pos = 0;
  while (pos < src.length) {
    const open = src.indexOf(`<${prefix}`, pos);
    if (open === -1) break;
    const nameEnd = src.indexOf(">", open);
    const name = tag(src.slice(open + prefix.length + 1, nameEnd));
    if (src[nameEnd - 1] === "/") {
      out.push({ name, inner: "" });
      pos = nameEnd + 1;
      continue;
    }
    const closeTag = `</${prefix}${name}>`;
    const close = src.indexOf(closeTag, nameEnd);
    if (close === -1) break;
    out.push({ name, inner: src.slice(nameEnd + 1, close) });
    pos = close + closeTag.length;
  }
  return out;
}

console.log(out.join("\n").replace(/\n{3,}/g, "\n\n"));
