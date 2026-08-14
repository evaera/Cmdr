// The Luau API pages are produced by docusaurus-plugin-moonwave, which
// shells out to the `moonwave-extractor` binary installed via Rokit.

const path = require("path");

const GIT_REPO_URL = "https://github.com/evaera/cmdr";
const GIT_SOURCE_BRANCH = "master";

module.exports = {
  title: "Cmdr",
  tagline: "The extensible command console for Roblox developers",
  titleDelimiter: "•",

  url: "https://eryn.io",
  baseUrl: "/Cmdr/",

  organizationName: "evaera",
  projectName: "Cmdr",
  deploymentBranch: "gh-pages",

  onBrokenLinks: "throw",
  markdown: {
    hooks: {
      onBrokenMarkdownLinks: "warn",
    },
  },

  themeConfig: {
    prism: {
      additionalLanguages: [
        "bash",
        "css",
        "javascript",
        "diff",
        "git",
        "json",
        "typescript",
        "toml",
      ],
    },

    navbar: {
      title: "",
      logo: {
        alt: "Cmdr",
        src: "/logo.png",
      },
      items: [
        {
          type: "doc",
          docId: "intro",
          position: "left",
          label: "Docs",
        },
        {
          to: "/api/",
          label: "API",
          position: "left",
        },
        {
          to: "/changelog",
          label: "Changelog",
          position: "left",
        },
        {
          href: `${GIT_REPO_URL}/releases`,
          label: "Releases",
          position: "right",
        },
        {
          href: "https://discord.gg/xFzPVg5WXm",
          label: "Discord",
          position: "right",
        },
        {
          href: GIT_REPO_URL,
          label: "GitHub",
          position: "right",
        },
      ],
    },

    footer: {
      style: "dark",
      copyright:
        'Built using Docusaurus and Moonwave. Released under the <a href="https://github.com/evaera/Cmdr/blob/master/LICENSE" target="_blank">MIT License</a>.',
      links: [
        {
          title: "Learn",
          items: [
            { label: "Introduction", href: "/docs/intro" },
            { label: "Best practice", href: "/docs/advanced/bestpractice" },
            { label: "API reference", href: "/api/Cmdr" },
            { label: "Changelog", href: "/changelog" },
          ],
        },
        {
          title: "Community",
          items: [
            { label: "Contribute", href: "/docs/contribute/index" },
            { label: "Security", href: "/docs/community/securityreport" },
            { label: "Discord", href: "https://discord.gg/xFzPVg5WXm" },
            {
              label: "Bug tracker",
              href: "https://github.com/evaera/Cmdr/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc",
            },
          ],
        },
      ],
    },

    colorMode: {
      respectPrefersColorScheme: true,
    },
  },

  plugins: [
    [
      "docusaurus-plugin-moonwave",
      {
        id: "moonwave",
        code: ["Cmdr"],
        sourceUrl: `${GIT_REPO_URL}/blob/${GIT_SOURCE_BRANCH}`,
        projectDir: path.join(__dirname, ".."),
        classOrder: [
          "Cmdr",
          "CmdrClient",

          "Registry",
          "Dispatcher",
          "Util",

          "CommandContext",
          "ArgumentContext",
        ],
        apiCategories: [],
      },
    ],
    "docusaurus-lunr-search",
  ],

  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          path: "../docs",
          editUrl: ({ docPath }) =>
            `${GIT_REPO_URL}/edit/${GIT_SOURCE_BRANCH}/docs/${docPath}`,
          sidebarCollapsible: true,
          sidebarPath: "./sidebars.js",
        },
        blog: false,
        pages: {
          path: "pages",
          exclude: ["_*.*"],
        },
        theme: {
          customCss: ["./src/css/custom.css"],
        },
      },
    ],
  ],
};
