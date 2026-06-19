# iris-interop-skills

A set of **17 Claude Code skills** for building **InterSystems IRIS For Health
Interoperability** productions — and a bank of worked examples and best practices
distilled from real-world integration projects.

These skills steer Claude when you design messages, wire Business Services /
Processes / Operations, write BPL and DTL transformations, author custom HL7 v2
schemas, build SOAP/REST/FHIR/DICOM endpoints, configure alerting and security,
and manage the production lifecycle — with a TDD-first workflow throughout.

> Originally built for the *"From Prompt to Production"* IRIS interoperability
> workshop. Published standalone so you can keep using the skills after the course.

## Quick start

Two steps, in order:

1. **Set up an IRIS MCP server** — the skills' runtime dependency (binary + `.mcp.json`): the
   original `iris-agentic-dev` **or** the streamlined `iris-interop-dev` fork (identical tool names —
   the skills work with either). See [*Set up the MCP server*](#set-up-the-iris-mcp-server).
2. **Install this plugin** — `/plugin marketplace add` + `/plugin install`.
   See [*Install*](#install).

## Requirements

- **Claude Code**.
- An **IRIS MCP server** (hard dependency) — `iris-agentic-dev` or the streamlined `iris-interop-dev`
  fork (identical tool names). The skills assume Claude can
  talk to a running IRIS for Health instance through it — load/compile classes,
  import schemas and lookups, run productions and unit tests, search messages.
- An IRIS For Health (or IRIS + Interoperability) instance to build against.

## Set up the IRIS MCP server

The skills drive IRIS through an MCP server exposing tools like `iris_compile`, `iris_doc`,
`iris_execute`, `iris_query`, `iris_test`. **Two interchangeable options — the skills work with
either, because the tool names are identical:**

- **`iris-agentic-dev`** (original) —
  [intersystems-community/iris-agentic-dev](https://github.com/intersystems-community/iris-agentic-dev).
- **`iris-interop-dev`** (streamlined interop fork) — a 20-tool, interop-focused profile with fixed
  `iris_execute` (real output capture), `iris_query` (SQL/table hints), and `iris_production`
  (works over HTTP, no Docker).

Register **one** of them in your `.mcp.json` (whichever binary you have). Each is a single
self-contained binary.

1. **Get the binary** — download the release asset for your platform from
   [Releases](https://github.com/intersystems-community/iris-agentic-dev/releases)
   (`iris-agentic-dev-windows-x86_64.exe`, `…-macos-arm64`, `…-linux-x86_64`), or on
   macOS: `brew tap intersystems-community/iris-agentic-dev && brew install iris-agentic-dev`.
   Put it somewhere on disk (e.g. `C:\iris-agentic-dev\iris-agentic-dev.exe`) and check it runs:
   `iris-agentic-dev --version`.

2. **Register it as an MCP server** — add a `.mcp.json` at your project root (or use
   `claude mcp add`). Point `command` at the binary and set the connection `env` to your IRIS:

   ```json
   {
     "mcpServers": {
       "iris-agentic-dev": {
         "command": "C:\\iris-agentic-dev\\iris-agentic-dev.exe",
         "args": ["mcp"],
         "env": {
           "IRIS_HOST": "localhost",
           "IRIS_WEB_PORT": "52773",
           "IRIS_USERNAME": "_SYSTEM",
           "IRIS_PASSWORD": "SYS",
           "IRIS_NAMESPACE": "USER"
         }
       }
     }
   }
   ```

   | Variable | Default | Notes |
   |---|---|---|
   | `IRIS_HOST` | `localhost` | Web gateway host |
   | `IRIS_WEB_PORT` | `52773` | Web gateway port (e.g. `80` for an IRIS community install behind the private web server) |
   | `IRIS_SCHEME` | `http` | `http` / `https` |
   | `IRIS_WEB_PREFIX` | _(empty)_ | URL path prefix for non-root installs (e.g. `irishealth`) |
   | `IRIS_USERNAME` / `IRIS_PASSWORD` | `_SYSTEM` / `SYS` | IRIS credentials |
   | `IRIS_NAMESPACE` | `USER` | Default namespace |

   > **Using the streamlined fork?** Replace the server key `iris-agentic-dev` with `iris-interop-dev`
   > (both in the `mcpServers` block above and in `enabledMcpjsonServers` below) and point `command` at
   > the `iris-interop-dev` binary. Nothing else changes — the tool names are identical, so the skills
   > and hooks work the same with either server.

3. **Enable + verify** — make sure the server is enabled for the project
   (`"enabledMcpjsonServers": ["iris-agentic-dev"]` in `.claude/settings.json`), restart Claude
   Code, and run the `check_config` tool to confirm it connects and the tools (`iris_doc`,
   `iris_compile`, `iris_execute`, `iris_query`, `iris_test`, …) are available.

## Install

1. **Add the marketplace + install the plugin:**

   ```text
   /plugin marketplace add PYDuquesnoy/iris-interop-skills
   /plugin install iris-interop-skills@iris-interop-skills
   ```

   This installs everything that ships with the plugin: the **17 skills**, the two **hooks**
   (silent-execute guard + TDD enforcement — auto-enabled), and the three **agents**
   (`interop-builder`, `deploy-smoke-test`, `introspect-dont-guess` — auto-registered; see *Agents* below).

2. **Required — raise the skill-listing budget.** Claude Code reserves ~1% of context for each skill's
   name + description; with a full skill set the two longest descriptions (the `interop` router and `tdd`)
   can be evicted and **stop auto-triggering**. Add these two keys to your **own** settings —
   `~/.claude/settings.json` (user) or `.claude/settings.json` (project):

   ```json
   {
     "skillListingBudgetFraction": 0.03,
     "skillListingMaxDescChars": 2048
   }
   ```

   This is a **user setting** — a plugin can't set it for you (see *Skill-listing budget* below).

3. **Work.** **Start at the `interop` router skill** — it routes to the right sibling skill and enforces
   messages-first (design the message class before BS/BP/BO). Or hand a whole component to the
   **`interop-builder`** agent and a wired production to **`deploy-smoke-test`**.

Prefer not to install as a plugin? Clone the repo and open it as a project — Claude discovers the skills
under `skills/`, the agents under `agents/`, and the examples under `BestPractices/`.

## What's inside

### Skills (`skills/`)

| Skill | Use it for |
|---|---|
| `interop` | **Router / index.** Start here; routes to the right skill and enforces messages-first. |
| `messages` | Designing message classes (the foundational building block). |
| `business-services` | Inbound Business Services (adapters, framing, schema category). |
| `business-operations` | Generic (non-SOAP) Business Operations. |
| `soap-bo` | SOAP Business Operations via the SOAP Wizard (and its gotchas). |
| `bpl` | BPL Business Processes and routing rules. |
| `transformations` | DTL data transformations, subtransforms, util functions. |
| `hl7-schemas` | Custom HL7 v2.x schemas — Z-segments, custom structures. |
| `lookup-tables` | Lookup tables — code maps, normalization, CSV sources. |
| `fhir` | FHIR endpoints — Façade vs Repository. |
| `dicom` | DICOM — C-STORE, MWL, Q/R, STOW-RS, DICOM↔HL7/FHIR. |
| `alerting` | The alert circuit — `Ens.Alert` routing + dedup. |
| `security` | Securing endpoints — SAML, OAuth 2.0, TLS/SSL. |
| `production-lifecycle` | The production class — items, settings, deploy, restart. |
| `message-search-debug` | Message search, Visual Trace, the Event Log. |
| `tdd` | TDD-first workflow (companion skill — load it alongside the others). |
| `unit-tests` | `%UnitTest` framework reference. |

### Agents (`agents/`)

Three subagents ship with the plugin and **auto-register on install** — invoke them by name, or let
Claude delegate based on the task description:

| Agent | Use it for |
|---|---|
| `interop-builder` | Build/modify any interop component end-to-end with TDD — loads the right skills, writes the test first, implements via the MCP, returns only when it compiles and the test is green. |
| `deploy-smoke-test` | Start a production, feed a sample input, and verify the message actually flowed (Event Log + Message Header + downstream target). |
| `introspect-dont-guess` | Resolve real class/table/column/config names from the live IRIS catalog instead of guessing (prevents nonexistent-table errors). |

The agents are **MCP-server-agnostic** (no server name pinned in their tools), so they work with either
the `iris-agentic-dev` or `iris-interop-dev` MCP.

### Best practices & worked examples (`BestPractices/`)

- `BestPractices_Interop_IRIS.md` — a synthesis of interoperability patterns,
  each tagged with a **Validity** and **Severity**.
- `examples/` — standalone, runnable code artefacts (`.cls` / `.xml` / `.sh`)
  for the trickier patterns, indexed by rule in `examples/README.md`. Several
  skills cite these as concrete worked examples.
- `external/workshop-iris-dicom-interop/` — a vendored MIT snapshot of the
  InterSystems Iberia DICOM-interop workshop, used by `iris-interop-dicom`.

All customer-identifying provenance has been removed from this public edition;
the patterns are vendor-neutral.

## Skill-listing budget (required user setting)

Claude Code reserves a slice of context (default ~1%) to inject each skill's **name +
description** into the system prompt. With many skills, or long descriptions, that budget
**overflows** and descriptions get truncated to the name — so the `interop` router and `tdd`
(the two longest, the ones carrying the routing and mandatory-companion rules) can drop out of
the listing and **stop auto-triggering**.

Raise the budget in your **own** settings — `~/.claude/settings.json` (user) or
`.claude/settings.json` (project):

```json
{
  "skillListingBudgetFraction": 0.03,
  "skillListingMaxDescChars": 2048
}
```

> The `settings.json` at the **root of this repo** records the recommended values, but a
> plugin-repo settings file is **not** auto-applied to end users — you must copy these two keys
> into your own settings. (Contrast with the hooks below, which *do* auto-enable on install.)

## Hooks

Two `PostToolUse` hooks ship in `hooks/` and auto-enable when the plugin is installed (wired via
`hooks/hooks.json`, referenced from `plugin.json`). Both are **advisory** (they never block) and
need **python3** on PATH; if python3 is absent they degrade to a no-op.

| Hook | Fires on | What it does |
|---|---|---|
| `silent-execute-guard` | `iris_execute` returning empty output (`success:true`, no captured output) | Reminds that HTTP CodeMode returns only what you `write`; wrap side-effecting code as a `[SqlProc]` and SELECT it, or verify with `iris_query`. |
| `tdd-enforcement` | `Write`/`Edit` of a `*.BO.*` / `*.BP.*` / `*DTL*` / `*Rule*` `.cls` with no sibling `*Test*.cls` | Reminds to write the test first (spec → test → red → implement → green; tests extend `%UnitTest.TestProduction`). |

Not installing as a plugin? Add the equivalent `hooks` block to your `settings.json`, pointing at
the `hooks/*.sh` wrappers.

## Decision log

- **Skill names are bare** (`tdd`, `messages`, …) and internally consistent — directory name =
  frontmatter `name:` = the router's references. The `iris-interop-tdd → tdd` rename (commit
  `c6da096`) created **no** dangling-reference bug; `iris-interop-skills:tdd` is the correct id.
- The real regressions that rename-commit introduced were: (a) it **shortened the 15 sibling
  descriptions** to ~70-char stubs, stripping their trigger keywords (restored here, bilingual
  ES/EN); and (b) the **bare-vs-qualified invocation trap** — `Skill("interop")` errors with
  "Unknown skill" while `Skill("iris-interop-skills:interop")` works (the router + CLAUDE.md now
  always use the qualified id, and the router lists the exact `Skill(...)` calls to make).
- **No skill was removed.** All 17 are intentional.

## License

MIT — see [`LICENSE`](LICENSE). The vendored DICOM snapshot keeps its own MIT
license under `BestPractices/external/workshop-iris-dicom-interop/LICENSE`.
