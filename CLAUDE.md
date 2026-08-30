# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A documentation-as-code **template**, built with Docusaurus 3 (classic preset, docs-only mode — blog is disabled and docs are served at `/` via `routeBasePath: '/'`), styled with the `cosmos-docusaurus-theme` (dark-first, CSS-only). There is no application code here; the "product" is the generated static site.

`content/` currently holds **sample content**, not meta-documentation about this template: it's a worked example for **Covenant**, a fictional .NET/Angular contract management system, showing what filled-in requirements/architecture/ADR/operations docs look like using this setup. When asked to change "the docs," check whether that means this sample content or the template/tooling itself (config, theme, sidebar structure) — they're different things living in the same repo.

The repo also doubles as a **copy-paste template**: it's designed to be copied wholesale into another project as `<project>/docs/` (see "Using this as a template" in `README.md`). That's why the Docusaurus content directory is `content/` rather than the more typical `docs/` — copying this repo's root into `<project>/docs/` would otherwise produce `<project>/docs/docs/`. `docusaurus.config.ts` sets `path: 'content'` on the docs preset to point at it.

## Commands

```bash
mise install        # provisions the Node version pinned in mise.toml (currently 24)
npm start          # local dev server with hot reload
npm run build       # production build -> build/
npm run serve       # serve a production build locally
npm run clear       # clear Docusaurus cache (.docusaurus/) — use when nav/config changes don't show up
npm run deploy       # docusaurus deploy (publishes via the configured deployment target)
npm run docusaurus  # raw Docusaurus CLI passthrough
```

There is no test suite and no lint script configured. `npm run build` is the closest thing to a correctness check — it runs with `onBrokenLinks: 'throw'`, so any broken internal doc link fails the build. Node version is pinned via `mise.toml`; there's no `.nvmrc` or `engines` field, so `mise install` is the canonical way to get the right version (plain `npm install` works too if Node 18+ is already on PATH some other way).

## Content architecture

- All content lives under `content/` as Markdown, one subdirectory per top-level section (`requirements/`, `architecture/`, `adr/`, `operations/`).
- **The sidebar is manually curated, not auto-generated.** `sidebars.ts` explicitly lists every doc/category; adding a new `.md` file under `content/` does nothing to the site nav until it's also added to `sidebars.ts`.
- Each doc file uses frontmatter (`title`, `sidebar_position`) to control its heading and ordering within its category.
- ADR filenames have no numeric prefix in their doc ID — Docusaurus strips leading `NNNN-` as an ordering convention, so a file named `content/adr/0001-foo.md` is referenced everywhere (sidebars.ts, links) as `adr/foo`, not `adr/0001-foo`. `sidebar_position` in frontmatter controls the actual ordering.
- `content/intro.md` is the site root (`slug: /`).

## Diagrams and math

Both are wired up and actually render (verified by rendering the built site in headless Chromium, not just by the build succeeding):
- **Mermaid** — fenced ` ```mermaid ` blocks render as SVG diagrams, client-side, via `@docusaurus/theme-mermaid` (`markdown.mermaid: true` + the theme in `themes: [...]` in `docusaurus.config.ts`). This theme requires `@mermaid-js/layout-elk` as a runtime dependency or the client bundle fails to compile — it's not auto-installed by `@docusaurus/theme-mermaid` itself.
- **Math** — `$...$` / `$$...$$` renders via `remark-math` + `rehype-katex`, wired into `presets[0].docs.remarkPlugins`/`.rehypePlugins`, with the KaTeX CSS pulled from a CDN via `stylesheets` in `docusaurus.config.ts` (no local `katex` package needed for styling).
- **C4 model diagrams (Structurizr)** — not a build-time pipeline like the other two. `workspace.dsl` (repo root) is a Structurizr DSL workspace modeling Covenant's C4 elements once; it's exported to Mermaid at authoring time (`docker run structurizr/structurizr export -f mermaid`, see `README.md`) and the output is hand-pasted into `.md` files as ordinary ` ```mermaid ` fences — nothing in `docusaurus.config.ts` or `package.json` is involved, since the committed artifact is plain Mermaid. **PlantUML/C4-PlantUML was tried first and dropped**: the public plantuml.com server has a confirmed, non-deterministic bug where the exact same encoded C4 diagram sometimes renders correctly and sometimes with overlapping/missing box titles (verified by re-fetching an identical URL repeatedly). Don't reintroduce a PlantUML remark plugin without solving that reliability problem first (e.g. a self-hosted, non-shared render server).

`.github/instructions/mermaid.instructions.md` and `.github/instructions/structurizr.instructions.md` define Copilot/VS Code-specific workflows for authoring Mermaid and Structurizr/C4 diagrams respectively. That tooling is VS Code/Copilot-specific and doesn't apply to Claude Code sessions, but the underlying convention both encode — validate diagram syntax before presenting it — is still worth following (e.g. by building the site and checking the diagram renders in headless Chromium). For Structurizr exports specifically, always strip the exporter's hardcoded `fill:#ffffff` style lines before committing (see `structurizr.instructions.md`) — otherwise the diagram renders as an opaque white box against this repo's dark theme.

## Publishing this site

`Dockerfile` builds the static site (`node:24-slim`, `npm ci` + `npm run build`, matching the Node version pinned in `mise.toml`); `.dockerignore` excludes `node_modules`/`build`/`.docusaurus`/`.git` from the build context. `.github/workflows/deploy.yml` runs that same Docker build on every push to `main` (and via manual `workflow_dispatch`), extracts `build/` from the built image with `docker cp`, and publishes it to GitHub Pages via the official `actions/upload-pages-artifact` + `actions/deploy-pages` actions — no `gh-pages` branch, no deploy keys. Don't confuse this with `content/operations/ci-cd.md` — that page describes a GitHub Actions pipeline for the *fictional Covenant application*, as sample content; it says nothing about how this documentation site itself gets built or deployed.

`docusaurus.config.ts`'s deployment values (`url`, `baseUrl`, `organizationName`, `projectName`, `presets[0].docs.editUrl`) are filled in for the actual current remote (`sszakal/x86cc.Documentation`, served at `https://sszakal.github.io/x86cc.Documentation/`) — not template placeholders anymore. Anyone copying this repo as a template (per README's "Using this as a template") needs to update all five to their own repo; `deploy.yml` itself doesn't hardcode the repo name and needs no changes. The one manual, non-code step is enabling **Settings → Pages → Source: GitHub Actions** on the repo — that can't be done from a config file.
