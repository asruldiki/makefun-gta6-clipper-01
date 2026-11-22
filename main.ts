// make.fun gta6-clipper-01 entry program.
// Deterministic: no network, no wall clock, stdlib only.
// Copies VIDEO.json from the bot dir to the output dir after validating the URL.
const fs = require('node:fs');
const path = require('node:path');

function dirFromEnv(name: string, fallback: string): string {
  const raw = process.env[name];
  const trimmed = typeof raw === 'string' ? raw.trim() : '';
  return trimmed.length > 0 ? trimmed : fallback;
}

function isYouTubeUrl(value: unknown): boolean {
  if (typeof value !== 'string' || value.length === 0) return false;
  let parsed: URL;
  try {
    parsed = new URL(value);
  } catch {
    return false;
  }
  if (parsed.protocol !== 'https:' && parsed.protocol !== 'http:') return false;
  const host = parsed.hostname.toLowerCase();
  return host === 'youtube.com' || host.endsWith('.youtube.com') || host === 'youtu.be' || host === 'www.youtu.be';
}

function main(): number {
  const botDir = dirFromEnv('MAKEFUN_BOT_DIR', '/bot');
  const outDir = dirFromEnv('MAKEFUN_OUTPUT_DIR', '/output');
  const src = path.join(botDir, 'VIDEO.json');

  let text: string;
  try {
    text = fs.readFileSync(src, 'utf8');
  } catch (err) {
    process.stderr.write(`cannot read ${src}: ${(err as Error).message}\n`);
    return 1;
  }

  let data: unknown;
  try {
    data = JSON.parse(text);
  } catch (err) {
    process.stderr.write(`VIDEO.json is not valid JSON: ${(err as Error).message}\n`);
    return 1;
  }

  if (data === null || typeof data !== 'object' || Array.isArray(data)) {
    process.stderr.write('VIDEO.json must be a JSON object\n');
    return 1;
  }

  const url = (data as { url?: unknown }).url;
  if (!isYouTubeUrl(url)) {
    process.stderr.write(`VIDEO.json url must be a youtube.com or youtu.be address, got: ${String(url)}\n`);
    return 1;
  }

  fs.mkdirSync(outDir, { recursive: true });
  const dest = path.join(outDir, 'VIDEO.json');
  // Re-serialize deterministically (2-space, trailing newline).
  fs.writeFileSync(dest, JSON.stringify(data, null, 2) + '\n', 'utf8');
  process.stdout.write(`wrote ${dest} -> ${String(url)}\n`);
  return 0;
}

process.exitCode = main();
