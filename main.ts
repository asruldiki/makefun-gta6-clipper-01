// make.fun gta6-clipper-01 entry: copy VIDEO.json to output after URL check.
// Deterministic, Node stdlib only, no network and no wall clock.
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

function envDir(name: string, fallback: string): string {
  const v = (process.env[name] ?? "").trim();
  return v === "" ? fallback : v;
}

function main(): number {
  const botDir = envDir("MAKEFUN_BOT_DIR", "/bot");
  const outDir = envDir("MAKEFUN_OUTPUT_DIR", "/output");
  const src = join(botDir, "VIDEO.json");

  let text: string;
  try {
    text = readFileSync(src, "utf8");
  } catch (e) {
    console.error(`cannot read ${src}: ${(e as Error).message}`);
    return 1;
  }

  let data: unknown;
  try {
    data = JSON.parse(text);
  } catch (e) {
    console.error(`invalid JSON: ${(e as Error).message}`);
    return 1;
  }
  if (data === null || typeof data !== "object" || Array.isArray(data)) {
    console.error("VIDEO.json must be a JSON object");
    return 1;
  }

  const rawUrl = (data as Record<string, unknown>).url;
  const url = typeof rawUrl === "string" ? rawUrl.trim() : "";
  let ok = false;
  try {
    const u = new URL(url);
    const host = u.hostname.toLowerCase();
    const webOk = u.protocol === "https:" || u.protocol === "http:";
    const hostOk = host === "youtube.com" || host.endsWith(".youtube.com") ||
      host === "youtu.be" || host.endsWith(".youtu.be");
    ok = webOk && hostOk;
  } catch {
    ok = false;
  }
  if (!ok) {
    console.error(`url is not a youtube.com or youtu.be address: ${url}`);
    return 1;
  }

  mkdirSync(outDir, { recursive: true });
  const dest = join(outDir, "VIDEO.json");
  writeFileSync(dest, JSON.stringify(data, null, 2) + "\n", "utf8");
  console.log(`wrote ${dest} (${url})`);
  return 0;
}

process.exitCode = main();
