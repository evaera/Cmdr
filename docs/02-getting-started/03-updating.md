# Updating

When a new version of Cmdr is released, you will want to update the library in your project to take advantage of new features, optimizations, and bug fixes. The update process depends entirely on the installation method you initially chose.

:::warning Back Up Your Custom Commands

Before updating, ensure your custom commands, types, and hooks are stored in their own separate folders outside of the Cmdr library directory. If you accidentally stored custom files inside the Cmdr folder, updating will overwrite them.

:::

---

## Model file (.rbxm)

If you installed Cmdr manually using the Roblox model file, follow these steps to replace the old version:

1. Visit the [latest release](https://github.com/evaera/Cmdr/releases/latest) page and download the new `Cmdr.rbxm` file from the Assets section.
2. Open your project in Roblox Studio.
3. Delete the existing `Cmdr` ModuleScript from your server directory (e.g., `ServerScriptService` or `ServerStorage`).
4. To bring the new version into your game, you can either:
   - Drag and drop the downloaded `Cmdr.rbxm` file directly into the viewport or the Explorer window.
   - Right-click your preferred directory in the **Explorer** panel, hover over **Insert**, click **Import Roblox Model**, navigate to the `Cmdr.rbxm` file, and click **Open**.
5. Ensure the new `Cmdr` ModuleScript is located in your preferred server directory.

---

## Wally

If you manage your packages using Wally and sync via Rojo, updating involves a quick tweak to your configuration file followed by your terminal workflow.

1. Open your `wally.toml` file.
2. Check your `Cmdr` entry. Wally treats version requirements as caret (`^`) matching by default. Writing `"evaera/cmdr@1.13.0"` behaves exactly like `"evaera/cmdr@^1.13.0"`, automatically permitting upgrades to the latest compatible minor or patch release.
3. Open your terminal in the project directory and pull the newest compatible versions by running:
   ```bash
   wally update
   ```
4. If you want to force an upgrade to a brand-new major version that falls outside your current range, manually change the version number string in your `wally.toml` to match the [latest release](https://github.com/evaera/Cmdr/releases/latest) version, then run `wally install`.
5. Run your Rojo sync command to push the updated `ServerPackages` into Roblox Studio.

---

## Git submodule

For advanced workflows using Rojo and Git submodules, updates can be handled either by consuming upstream releases or by keeping collaborators in sync.

### Pulling upstream changes

If you simply want to pull down the latest updates from the remote Cmdr repository into your project:

1. Run the remote update command from your main repository root to fetch and check out the latest tracking commit:
   ```bash
   git submodule update --remote Cmdr
   ```
   _Note: Git will default to checking out the remote's HEAD commit._

### Synchronizing collaborators

If another developer on your team updated the Cmdr submodule version and committed the reference pointer to the main repository, running a basic `git pull` will fetch the changes but leave your local submodule directory unmodified.

1. Pull the new parent configuration and automatically update the submodule in one step:
   ```bash
    git pull --recurse-submodules
   ```
2. Alternatively, if you did a standard pull, finalize the sync to match the target commit by running:
   ```bash
   git submodule update --init
   ```
   _Note: Using the `--init` flag ensures that the submodule is properly initialized and fetched if it was recently added to the repository layout._

:::tip Avoid Detached HEAD State

By default, running `git submodule update` places the sub-repository into a "detached HEAD" state, meaning changes are not tracked by a local working branch. If you intend to modify the Cmdr source code locally, remember to navigate into the submodule folder (`cd Cmdr`) and check out a dedicated working branch (e.g., `git checkout master`) before editing.

:::

---

## Manual repository clone

If you downloaded the source code directly via `git clone` or a ZIP download:

1. Delete your old local copy of the `Cmdr` source directory.
2. Download the source code from the [latest release](https://github.com/evaera/Cmdr/releases/latest) page.
3. Extract the folder, pull out the inner `Cmdr` library directory, and place it back into your project workspace where Rojo can track it.
