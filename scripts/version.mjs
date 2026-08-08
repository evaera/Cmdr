import { readFile, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

import semver from "semver";

const projectDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");

const [version, ...extra] = process.argv.slice(2);

if (version === undefined || extra.length > 0) {
  console.error("Usage: node scripts/version.mjs <version>");
  process.exit(1);
}

// This gets a dedicated error because it's such a likely mistake.
if (version.startsWith("v")) {
  throw new Error(
    `Invalid version: ${version}. Versions must not be prefixed with a v.`,
  );
}

if (semver.valid(version) !== version) {
  throw new Error(
    `Invalid version: ${version}. Must be a canonical version, e.g. 1.13.0 or 1.13.0-rc.2.`,
  );
}

// Replaces the first line matching `pattern`. Fails loudly rather than silently
// leaving a file behind at the old version.
async function replaceLine(relativePath, pattern, replacement) {
  const path = resolve(projectDir, relativePath);
  const contents = await readFile(path, "utf8");

  if (!pattern.test(contents)) {
    throw new Error(
      `Could not find a version line to replace in ${relativePath}`,
    );
  }

  await writeFile(path, contents.replace(pattern, replacement), "utf8");
  console.log(`Updated ${relativePath}`);
}

async function updateJson(relativePath, update) {
  const path = resolve(projectDir, relativePath);
  const data = JSON.parse(await readFile(path, "utf8"));

  update(data);

  await writeFile(path, `${JSON.stringify(data, null, 2)}\n`, "utf8");
  console.log(`Updated ${relativePath}`);
}

await replaceLine(
  "wally.toml",
  /^version\s*=\s*.*$/m,
  `version = "${version}"`,
);

await updateJson("package.json", (data) => {
  data.version = version;
});

await updateJson("package-lock.json", (data) => {
  data.version = version;
  data.packages[""].version = version;
});

await replaceLine(
  "Cmdr/BuiltInCommands/Debug/version.luau",
  /^const VERSION = ".*"$/m,
  `const VERSION = "v${version}"`,
);
