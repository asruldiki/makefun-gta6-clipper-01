// Copies VIDEO.json from the bot repo root into the output directory.
// Deterministic, stdlib only. Refuses URLs that are not YouTube.
import { copyFileSync, mkdirSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";

const botDir = resolve(process.env.MAKEFUN_BOT_DIR ?? "/bot");
const outDir = resolve(process.env.MAKEFUN_OUTPUT_DIR ?? "/output");
const src = join(botDir, "VIDEO.json");

const raw = readFileSync(src, "utf8");
let meta: { url?: unknown };
try {
  meta = JSON.parse(raw);
} catch {
  console.error("VIDEO.json is not valid JSON");
  process.exit(1);
}
const url = typeof meta.url === "string" ? meta.url.trim() : "";
if (!/^https?:\/\/(www\.)?(youtube\.com|youtu\.be)\//i.test(url)) {
  console.error(`VIDEO.json url is not a YouTube link: ${JSON.stringify(url)}`);
  process.exit(1);
}

mkdirSync(outDir, { recursive: true });
copyFileSync(src, join(outDir, "VIDEO.json"));
console.log(`copied VIDEO.json -> ${outDir}/VIDEO.json (${url})`);