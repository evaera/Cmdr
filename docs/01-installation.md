# Installation

Cmdr has no dependencies which makes it incredibly portable and easy to include in your game.

We recommend installing Cmdr in a place only visible on the server (such as `ServerScriptService` or `ServerStorage`) as this provides better optimisation and guards against mistakes. Plus, there have been reports of unexpected issues caused by installing Cmdr in a shared place (like `ReplicatedStorage`).

You can choose one of many installation methods. While there are other potential installation methods, we recommend sticking to one of the below, unless you're sure you know what you're doing.

:::info Heads up

There are plenty of resources available to help you with Cmdr, such as this website and our Discord server, but we've been made aware of a number of DevForum guides and YouTube videos which provide incorrect or outdated instructions.

**We recommend you stick to our official resources, especially if you're new to Cmdr.** If you decide to use unofficial resources, then the level of support we can provide (for instance in our Discord server) is limited.

:::

:::warning Do not modify the source code

Please **do not** modify the source code of Cmdr for your game. Instead, use its API to customise the behaviour you want. Modifying the source code makes it much harder for you to receive future updates.

There shouldn't be any reason why you need to modify the source code of Cmdr (unless you're [adding a new feature or fixing a bug](/docs/contribute)). If there's something you think we're missing, please [open an issue](https://github.com/evaera/cmdr/issues).

:::

## Model file (recommended)

1. You can visit the [latest release](https://github.com/evaera/Cmdr/releases/latest) page. At the bottom of the page, you'll find an "Assets" section, then download `Cmdr.rbxm`

If you're using Roblox Studio:

1. You can either:
   - drag or drop the `Cmdr.rbxm` file into the viewport (central window)
   - select the `Model` tab, then under the `Advanced` section click `Model`. Then, navigate to the `Cmdr.rbxm` file and click `Open`
2. Make sure you move the `Cmdr` ModuleScript to wherever you want it (as above, we recommend you keep it on the server)
3. Proceed to [Setup](/docs/setup)

If you're using Rojo, you can either add the `Cmdr.rbxm` file to your project file (usually called `default.project.json`), or put the `Cmdr.rbxm` file into a directory that you've got set up to sync already. [Rojo's documentation](https://rojo.space) can help you with this.

## Wally (recommended) (requires Rojo)

Cmdr is published on the wally registry as [`evaera/cmdr`](https://wally.run/package/evaera/cmdr); you should be cautious about the potential for malware and **only use the official package**.

You can easily add Cmdr to your project's `wally.toml` file. If you're experiencing difficulties, [Wally's documentation](https://github.com/UpliftGames/wally#manifest-format) can help.

We recommend adding Cmdr to the 'server realm', you can do this by putting it under the `server-dependencies` section. This'll put it in a `ServerPackages` folder (which you'll then need to sync into your game using Rojo).

```toml
[server-dependencies]
Cmdr = "evaera/cmdr@^1.9.0"
```

Make sure you check what the [latest version](https://github.com/evaera/Cmdr/releases/latest) is. The caret (^) will tell Wally to automatically upgrade to the newest compatible version if available, which we recommend doing.

## Submodule (advanced) (requires Rojo)

If your project is using Rojo and Git, then you can use Git Submodules to include Cmdr into your project, and then sync it into your game using Rojo.

This will include a lot of unnecessary files into your project though, like the website and documentation, so you should make sure you only pull or sync the `Cmdr` directory (which is the library source code).

We recommend 'pinning' to the [latest version](https://github.com/evaera/Cmdr/releases/latest)'s tag, rather than using the `master` branch. This is because pre-release versions may have unexpected bugs, glitches or changes, and we may not be able to offer you support unless you're using the latest released version.

## Manual (not recommended) (requires Rojo)

Using `git clone` or GitHub's Download button, you can download a copy of the source code and then take the `Cmdr` directory and sync this into your place.

We recommend downloading the [latest version](https://github.com/evaera/Cmdr/releases/latest) rather than using the `master` branch. This is because pre-release versions may have unexpected bugs, glitches or changes, and we may not be able to offer you support unless you're using the latest released version.

## Roblox models (not supported)

Cmdr is not published to the Roblox creator marketplace. Owing to the prevalence of malware, you **should not use any publish of Cmdr on the Roblox library**, and instead use one of the above installation methods.

If you're experiencing difficulties and need help, then you can find advice on getting help [in the Introduction page](/docs/intro).
