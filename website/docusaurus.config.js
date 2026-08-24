// The Luau API pages are produced by docusaurus-plugin-moonwave, which
// shells out to the `moonwave-extractor` binary installed via Rokit.

const path = require("path");

const GIT_REPO_URL = "https://github.com/evaera/cmdr";
const GIT_SOURCE_BRANCH = "master";

const LATEST_VERSION = require("../package.json").version;

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

  themeConfig: {
    prism: {
      additionalLanguages: ["bash", "diff", "toml"],
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
          label: /[\-]/.test(LATEST_VERSION)
            ? LATEST_VERSION
            : `Latest: ${LATEST_VERSION}`,
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
            { label: "API reference", href: "/api/Cmdr" },
            { label: "Changelog", href: "/changelog" },
            { label: "Cookbook", href: "/docs/cookbook" },
          ],
        },
        {
          title: "Community",
          items: [
            { label: "Discord", href: "https://discord.gg/xFzPVg5WXm" },
            {
              label: "Bug tracker",
              href: "https://github.com/evaera/Cmdr/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc",
            },
            { label: "Contribute", href: "/docs/contribute" },
            {
              label: "Report vulnerability",
              href: "/docs/securityreport",
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
    [
      "@docusaurus/plugin-client-redirects",
      {
        // prettier-ignore
        redirects: [
          { from: "/docs", to: "/docs/intro" },
          { from: "/docs/getting-started/installation", to: "/docs/installation" },
          { from: "/docs/getting-started/setup", to: "/docs/setup" },
          { from: "/docs/getting-started/updating", to: "/docs/updating" },

          { from: "/docs/reference/commands", to: "/docs/commands" },
          { from: "/docs/reference/hooks", to: "/docs/hooks" },
          { from: "/docs/reference/types", to: "/docs/types" },
          { from: "/docs/reference/metacommands", to: "/docs/metacommands", },
          { from: "/docs/reference/networkeventhandlers", to: "/docs/networkeventhandlers" },
          { from: "/docs/reference/autoexec", to: "/docs/autoexec" },
          { from: "/docs/commands-reference/commands", to: "/docs/commands" },
          { from: "/docs/commands-reference/hooks", to: "/docs/hooks" },
          { from: "/docs/commands-reference/types", to: "/docs/types" },
          { from: "/docs/commands-reference/metacommands", to: "/docs/metacommands", },
          { from: "/docs/commands-reference/networkeventhandlers", to: "/docs/networkeventhandlers" },
          { from: "/docs/commands-reference/autoexec", to: "/docs/autoexec" },

          { from: "/docs/advanced/permissions", to: "/docs/permissions" },
          { from: "/docs/advanced/customizinginterface", to: "/docs/customizinginterface" },
          { from: "/docs/advanced/customisinginterface", to: "/docs/customizinginterface" },
          { from: "/docs/customisinginterface", to: "/docs/customizinginterface" },
          { from: "/docs/advanced/guards", to: "/docs/guards" },
          { from: "/docs/advanced/customtypes", to: "/docs/customtypes" },
          { from: "/docs/advanced/security", to: "/docs/security" },
          { from: "/docs/community/cookbook", to: "/docs/cookbook" },
          { from: "/docs/community/securityreport", to: "/docs/securityreport" },
        ],
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
