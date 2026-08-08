// Copies CHANGELOG.md into pages/ so Docusaurus serves it at /changelog.
// The generated file is gitignored, run this before `docusaurus start|build`.
// (but if the file is missing, everything should still work)

import { copyFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

// I don't know why Claude did it this complex when __dirname is right there.
// But it works, so I'm not touching it.
const projectDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");

const source = resolve(projectDir, "CHANGELOG.md");
const target = resolve(projectDir, "website/pages", "changelog.md");

await copyFile(source, target);
