---
applyTo: "**"
---
# Structurizr / C4 model AI Skills

When the user asks to create, edit, or visualize a C4 model diagram (System
Context, Container, Component, Deployment), model it in `workspace.dsl` at
the repo root and export it to Mermaid — do not hand-write C4 diagrams
directly, and do not reach for PlantUML/C4-PlantUML (this repo doesn't wire
that up; see below for why).

## How this repo does C4 diagrams

`workspace.dsl` (repo root) is a [Structurizr](https://structurizr.com/) DSL
workspace: one `model` block declares people/software systems/containers
once, and a `views` block derives one or more diagrams from that same model
(no redeclaring elements per diagram). It is exported to Mermaid at
authoring time — the generated Mermaid text is then hand-pasted into the
`.md` file it documents as an ordinary ` ```mermaid ` fence, the same way
this repo's other Mermaid diagrams are authored. There is no live/runtime
export step: the site only ever renders plain Mermaid.

**Why not PlantUML/C4-PlantUML:** it was tried first and dropped. Rendering
a `.plantuml` fence to text is a public plantuml.com server dependency, and
that server has a confirmed, non-deterministic rendering bug for C4 diagrams
with several elements — the exact same encoded diagram sometimes renders
correctly and sometimes renders with box titles overlapping or missing
(verified by re-fetching an identical URL repeatedly). Structurizr → Mermaid
export sidesteps this entirely: Mermaid renders client-side via this repo's
already-reliable `@docusaurus/theme-mermaid` pipeline, so there's no
third-party rendering server in the loop at all once the diagram is
committed.

## Workflow

1. Edit `workspace.dsl` — add/update `person`, `softwareSystem`, `container`,
   and `component` elements in the `model` block, and add a matching view
   (`systemContext`, `container`, `component`, `deployment`) in the `views`
   block if this is a new diagram.
2. Export to Mermaid using the Structurizr CLI Docker image (no local Java
   needed):
   ```bash
   docker run --rm -v "$(pwd)":/workspace -v /tmp/structurizr-export:/output \
     structurizr/structurizr export -w /workspace/workspace.dsl -f mermaid -o /output
   ```
   (Create `/tmp/structurizr-export`, world-writable, before running — the
   container writes as a non-root user.)
3. **Strip the hardcoded white-background styling** the exporter always
   emits before pasting the diagram in: remove the
   `linkStyle default fill:#ffffff` line and every
   `style <id> fill:#ffffff,stroke:...,color:...` line. Leave `style`
   lines that aren't plain white overrides (e.g. shape-only styles) alone.
   Without this step the diagram renders as an opaque white box that clashes
   with this repo's dark-first theme — the existing hand-written Mermaid
   diagrams in this repo have no style overrides at all, and these shouldn't
   either.
4. Paste the cleaned Mermaid (`graph LR ...`) into the `.md` file as a
   ` ```mermaid ` fence, directly under the `##` heading it documents,
   followed by 1-3 sentences of prose — same convention as this repo's other
   diagrams.
5. Validate by building the site (`npm run build`) and viewing the page —
   Mermaid renders client-side, so a build success does not by itself
   confirm the diagram displays correctly.

## Rules

1. Model elements once in `workspace.dsl`; derive views from it. Don't
   hand-write a second, independent Mermaid diagram that duplicates elements
   already in the model — regenerate from the DSL instead so multiple views
   of the same diagram stay consistent.
2. Always strip the exporter's `fill:#ffffff` style lines before committing
   (step 3 above) — this is the one required post-processing step.
3. Commit the generated Mermaid as plain text directly in the `.md` file;
   there is no build-time Structurizr dependency, so nothing needs wiring
   into `docusaurus.config.ts`.
4. Do not introduce PlantUML/C4-PlantUML rendering — it was evaluated and
   dropped for this repo due to the plantuml.com reliability issue above.
5. Match the existing content style: concrete technology names in labels
   (e.g. `WolverineFX.Http`, `Marten, PostgreSQL`, `LavinMQ`), 1-3 sentences
   of prose directly under the fence, flat `##` heading level.

## Docs

- Structurizr DSL language reference: https://docs.structurizr.com/dsl/language
- Structurizr CLI export command: https://docs.structurizr.com/cli/export
- C4 model: https://c4model.com/
