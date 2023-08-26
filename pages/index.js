import useDocusaurusContext from "@docusaurus/useDocusaurusContext"
import React from "react"

import Layout from "@theme/Layout"
import Link from "@docusaurus/Link"

import styles from "./index.module.css"

function Header() {
  const { siteConfig } = useDocusaurusContext()
  return (
    <header className={styles.heroBanner}>
      <div className="container">
        <h1 className="hero__title">Cmdr</h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className={`button button--success button--lg ${styles.button}`}
            to="/guide"
          >
            Get Started →
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
      <Header />
      <main>
        <p className={styles.tagline}>
          Cmdr is a fully extensible command console for Roblox developers.
        </p>

        <div className="container">
          <section className={styles.featuresOuter}>
            <div className={styles.featuresInner}>
              <Feature title="Integrates with your systems" description="Make commands that integrate and control your existing systems. Use commands to help debug your game during development by triggering events in your game or print out targeted debug information." />
              <Feature title="Type-Safe with Intelligent Auto-completion" description="Discover commands and possible values for arguments naturally with game-state-aware auto-complete. Argument types are validated on the client and server, so in your command code you never have to worry about an argument being of the wrong type or missing." />
              <Feature title="100% Extensible" description="Cmdr ships with a set of optional default commands for the very most commonly used commands for debugging your game, but the real power of Cmdr is its extensibility. You can register your own commands and argument types so Cmdr can be exactly what you need it to be." />
            </div>
          </section>

          <p className={styles.paragraphs}>
            Cmdr is designed specifically so that you can write your own commands and argument types, so that it can fit right in with the rest of your game. In addition to the standard admin commands (teleport, kill, kick), Cmdr is also great for debug commands in your game (say, if you wanted to have a command to give you a weapon, reset a round, teleport you between places in your universe).
          </p>

          <p className={styles.paragraphs}>
          Cmdr provides a friendly API that lets the game developer choose if they want to register the default admin commands, register their own commands, choose a different key bind for activating the console, and disabling Cmdr altogether.
          </p>

          <p className={styles.paragraphs}>
          Cmdr has a robust and friendly type validation system (making sure strings are strings, players are players, etc), which can give end users real time command validation as they type, and automatic error messages. By the time the command actually gets to your code, you can be assured that all of the arguments are present and of the correct type.
          </p>
        </div>
      </main>
    </Layout>
  )
}
