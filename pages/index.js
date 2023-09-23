import useDocusaurusContext from "@docusaurus/useDocusaurusContext"
import React from "react"

import Layout from "@theme/Layout"
import Admonition from "@theme/Admonition"
import Link from "@docusaurus/Link"

import styles from "./index.module.css"

function Hero() {
  const { siteConfig } = useDocusaurusContext()
  return (
    <header className={styles.heroBanner}>
      <div className="container">
        <h1 className="hero__title">Cmdr</h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className={`button button--success button--lg ${styles.button}`}
            to="/docs/intro"
          >
            Get Started
          </Link>

          <Link
            className={`button button--secondary button--lg ${styles.button}`}
            to="/api"
          >
            API Documentation
          </Link>
        </div>
      </div>
    </header>
  )
}

function Feature({ title, description }) {
  return (
    <div className={styles.feature}>
      <h3>{title}</h3>
      <p>{description}</p>
    </div>
  )
}

export default function Home() {
  const { tagline } = useDocusaurusContext()
  return (
    <Layout title="" description={tagline}>
      <Hero />
      <main>
        <div className="container">
          <Admonition type="info" title="Beta">
            This website is a new service and <a href="https://github.com/evaera/Cmdr/issues/new?assignees=&labels=scope%3Aixp&projects=&template=websitefeedback.md" target="_blank">your feedback</a> will help improve it. In the mean time, you may find it helpful to refer to <a href="https://eryn.io/Cmdr" target="_blank">the current documentation</a>.
          </Admonition>

          <section className={styles.featuresOuter}>
            <div className={styles.featuresInner}>
              <Feature title="Integrates with your systems" description="Cmdr stays out of the way, making it easy to write your own commands which plug-in to your systems. Help debug your game by triggering events or printing useful data." />
              <Feature title="Type-safe with intelligent autocomplete" description="Discover commands and possible values for arguments naturally with context-aware autocomplete. Arguments are strictly typed and validated for you, keeping typos at bay." />
              <Feature title="Powerful and extensible" description="Cmdr ships with optional built-in commands but you can register your own commands and types. Meta-commands like bind and alias make it possible to extend Cmdr even further." />
            </div>
          </section>

          <p className={styles.paragraphs}>
            While Cmdr was originally designed to make debugging easier, Cmdr has been popularised as a general console and command system due to its powerful features and extensible nature. Of course, you don't need to use it for debugging; Cmdr can be used in whatever way works for you
          </p>

          <p className={styles.paragraphs}>
            Cmdr provides a friendly API that lets developers choose how they want Cmdr to work, to register their own commands, choose a different key bind for activating the console, or even disable Cmdr altogether.
          </p>

          <p className={styles.paragraphs}>
            Cmdr has a robust and friendly type validation system which gives users real-time feedback as they type. By the time the command actually gets to your code, you can be assured that all of the arguments are present and of the correct type, keeping both typos and exploiters at bay.
          </p>

          <p className={styles.paragraphs}>
            Cmdr has been around for over five years and is trusted in games with billions of visits earning millions of dollars worth of revenue. <Link to="/docs/intro#why-should-i-use-it">Tell me more →</Link>
          </p>
        </div>
      </main>
    </Layout>
  )
}
