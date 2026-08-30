# x86cc.Documentation

A documentation-as-code template: Markdown content, built into a static site with [Docusaurus](https://docusaurus.io/), with diagrams (Mermaid, plus C4 model diagrams authored in [Structurizr](https://structurizr.com/) DSL and exported to Mermaid) and math (KaTeX) rendered inline. The [Cosmos](https://sckyzo.github.io/cosmos-docusaurus-theme) theme provides the look and feel.

The content currently in `content/` is a worked example — **Covenant**, a fictional contract management system — showing what filled-in requirements, architecture, ADR, and operations docs look like using this setup. See it live by running the site locally (below), starting from `content/intro.md`.

## Prerequisites

This repo pins its Node version with [mise](https://mise.jdx.dev/) via `mise.toml` (currently Node 24).

```bash
mise install   # installs the pinned Node version into this project
```

If you don't use mise, any Node 18+ works — just install it however you normally do (nvm, fnm, a system package, etc).

## Getting started

```bash
npm install
npm start
```

This starts the dev server at `http://localhost:3000` with hot reload.

## Other commands

```bash
npm run build   # production build -> build/
npm run serve   # serve a production build locally
npm run clear   # clear the Docusaurus cache (.docusaurus/) if nav/config changes don't show up
```

There's no test suite; `npm run build` is the correctness check — it's configured to fail (`onBrokenLinks: 'throw'`) on any broken internal doc link.

## Building with Docker

```bash
docker build -t x86cc-documentation .
docker create --name extract x86cc-documentation
docker cp extract:/app/build ./build
docker rm extract
```

This builds the site the same way locally and in CI, without needing Node/mise installed on the host — only Docker. It's the same `Dockerfile` the GitHub Actions deploy workflow uses (see below).

## Deployment

`.github/workflows/deploy.yml` builds the site via Docker and publishes it to GitHub Pages on every push to `main` (or manually via the Actions tab), using the official `actions/upload-pages-artifact` + `actions/deploy-pages` actions — no `gh-pages` branch or deploy keys involved. The one manual prerequisite: in the repo's **Settings → Pages**, set **Source** to **GitHub Actions** (one-time setup). Once that's done, the site is live at `https://sszakal.github.io/x86cc.Documentation/`.

## How this setup was assembled

For reproducing an equivalent setup elsewhere, here's what's installed on top of a base Docusaurus classic + TypeScript site, and what each addition touches in `docusaurus.config.ts`:

| Package | Adds | Config touched |
|---|---|---|
| `cosmos-docusaurus-theme` | Dark-first CSS theme | `themes: [...]`, `themeConfig.colorMode` |
| `@docusaurus/theme-mermaid` + `@mermaid-js/layout-elk` | Renders ` ```mermaid ` code fences as diagrams | `themes: [...]`, `markdown.mermaid: true` |
| `remark-math` + `rehype-katex` | Renders `$...$` / `$$...$$` as math | `presets[0].docs.remarkPlugins` / `.rehypePlugins`, plus a KaTeX CSS `stylesheets` entry |

`docusaurus.config.ts` is the source of truth for exact wiring; the table above is just the map of "why is this dependency here."

## C4 model diagrams (Structurizr)

C4 model diagrams (System Context, Container, etc.) are authored once as a [Structurizr](https://structurizr.com/) DSL workspace in `workspace.dsl` at the repo root, then exported to Mermaid and committed as ordinary ` ```mermaid ` fences — see the diagrams in `content/architecture/overview.md` for an example. This is an authoring-time step, not a runtime dependency: nothing in `docusaurus.config.ts` or `package.json` is involved, since the exported output is plain Mermaid text rendered by the same pipeline as this repo's other diagrams.

```bash
mkdir -p /tmp/structurizr-export && chmod 777 /tmp/structurizr-export
docker run --rm -v "$(pwd)":/workspace -v /tmp/structurizr-export:/output \
  structurizr/structurizr export -w /workspace/workspace.dsl -f mermaid -o /output
```

Before pasting the result into a `.md` file, strip the `linkStyle default fill:#ffffff` line and every `style <id> fill:#ffffff,...` line the exporter emits — otherwise diagrams render as opaque white boxes that clash with this repo's dark-first theme. See `.github/instructions/structurizr.instructions.md` for the full workflow.

C4-PlantUML was evaluated first and dropped: the public plantuml.com server has a confirmed, non-deterministic bug rendering C4 diagrams with several elements (the same encoded diagram sometimes renders correctly and sometimes with corrupted text). Structurizr → Mermaid export avoids a rendering server entirely.

## Content layout

Docusaurus content lives in `content/`, not the more usual `docs/` — see [Using this as a template](#using-this-as-a-template) for why. The sidebar (`sidebars.ts`) is manually curated: adding a new `.md` file under `content/` doesn't add it to the site nav until it's also listed there.

## Using this as a template

This repo is meant to be copied into another project as its `docs/` folder — the whole repo root becomes `<project>/docs/`:

```bash
git clone https://github.com/your-org/x86cc.Documentation.git /path/to/your-project/docs
rm -rf /path/to/your-project/docs/.git
cd /path/to/your-project/docs
mise install   # or ensure Node 18+ some other way
npm install
npm start
```

The Docusaurus content lives in `content/`, not `docs/`, specifically so this nests cleanly as `<project>/docs/content/...` instead of `<project>/docs/docs/...` when copied in this way. Once copied, replace the sample `content/` with your own project's docs, and update the deployment values to point at your own repo: `url`, `baseUrl`, `organizationName`, `projectName`, and `presets[0].docs.editUrl` in `docusaurus.config.ts` currently point at `sszakal.github.io/x86cc.Documentation` — change all of them (and the `deploy.yml` workflow needs no changes itself, since it doesn't hardcode the repo name).
