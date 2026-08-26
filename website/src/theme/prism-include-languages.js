import siteConfig from "@generated/docusaurus.config";
import prismLuau from "./prism-luau";

export default function prismIncludeLanguages(PrismObject) {
  const {
    themeConfig: { prism },
  } = siteConfig;

  const { additionalLanguages } = prism;

  const PrismBefore = globalThis.Prism;
  globalThis.Prism = PrismObject;

  additionalLanguages.forEach((lang) => {
    // eslint-disable-next-line global-require, import/no-dynamic-require
    require(`prismjs/components/prism-${lang}`);
  });

  prismLuau(PrismObject);

  delete globalThis.Prism;

  if (typeof PrismBefore !== "undefined") {
    globalThis.Prism = PrismObject;
  }
}
