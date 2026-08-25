**prepare for release**

0. make sure `@unreleased` moonwave tags are updated to `@since` – the docs site shows the latest released version at the top, so we have to be careful about unreleased features showing up in the API
1. `npm run set-version 1.14.0`
2. check diffs: make sure you haven't accidentally clobbered wally, etc.
3. write your changelog
4. push to master so that way you build and submit from github's head (which'll be the same head the tag is made from)
   - GitHub gives you bonus points if the commit is signed.
5. update and [publish docs](/.github/workflows/deploy-site.yml) and make sure they're live

**actually do the release**

GitHub's releases UI will create a tag for you (and sign it for you). You might create a draft release so you can get the pull requests and new contributors headings.

`rojo build` with `default.project.json` will allow you to generate the `Cmdr.rbxm`, attach it to the GitHub release before you publish it.

You'll need to log into wally (`wally login`) and then run `wally publish`. I haven't done this so can't tell you how it works (or doesn't) lol.
