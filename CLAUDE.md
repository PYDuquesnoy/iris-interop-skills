# iris-interop-skills

A standalone plugin of **17 skills** for building InterSystems IRIS For Health
Interoperability productions with Claude, plus a best-practices + worked-examples
bank under `BestPractices/`.

## Skills system

When working on anything IRIS Interoperability, invoke the `interop` router skill.
It assumes the **`iris-agentic-dev` MCP server** is enabled (hard dependency).

**Messages are the foundational building block** — design the message class before
BS/BP/BO. The `interop` router skill enforces this and points to the right
sibling skill for each task. Always load `tdd` as a companion.

## Layout

- `skills/*/SKILL.md` — the 17 skills. Each is a single `SKILL.md`.
  The router (`interop`) refers to its siblings by **skill name**
  (e.g. `messages`, `business-services`), not by path.
- `BestPractices/` — the worked-example bank the skills cite:
  - `BestPractices_Interop_IRIS.md` — patterns tagged Validity/Severity.
  - `examples/` — runnable artefacts indexed in `examples/README.md`.
  - `external/workshop-iris-dicom-interop/` — vendored MIT DICOM snapshot.
- `.claude-plugin/` — `marketplace.json` + `plugin.json` (this repo is both a
  single-plugin marketplace and the plugin itself; plugin `source` is the repo root).

## Conventions for editing skills

- Skills reference the worked examples via `${CLAUDE_PLUGIN_ROOT}/BestPractices/…`
  so the path resolves whether the plugin is installed from the marketplace or the
  repo is cloned and opened as a project. Keep that prefix when adding references.
- Keep skills **self-sufficient**: a referenced example must travel inside this repo
  (under `BestPractices/`). No pointers to files outside the repo.
- This public edition carries **no customer-identifying provenance**. Don't
  reintroduce client/site names, internal document names, or real endpoints when
  editing — keep examples vendor-neutral (`Demo.*` package names, `example.org`
  hosts, generic descriptors).
