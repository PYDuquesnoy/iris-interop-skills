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

## Requirements

- **Claude Code**.
- The **`iris-agentic-dev` MCP server** (hard dependency). The skills assume Claude can
  talk to a running IRIS for Health instance through it — load/compile classes,
  import schemas and lookups, run productions and unit tests, search messages.
- An IRIS For Health (or IRIS + Interoperability) instance to build against.

## Set up the `iris-agentic-dev` MCP server

The skills drive IRIS through the **`iris-agentic-dev`** MCP server
([intersystems-community/iris-agentic-dev](https://github.com/intersystems-community/iris-agentic-dev)),
a single self-contained binary.

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

3. **Enable + verify** — make sure the server is enabled for the project
   (`"enabledMcpjsonServers": ["iris-agentic-dev"]` in `.claude/settings.json`), restart Claude
   Code, and run the `check_config` tool to confirm it connects and the tools (`iris_doc`,
   `iris_compile`, `iris_execute`, `iris_query`, `iris_test`, …) are available.

## Install

```text
/plugin marketplace add PYDuquesnoy/iris-interop-skills
/plugin install iris-interop-skills@iris-interop-skills
```

Then just work on IRIS interoperability tasks — the skills activate by topic.
**Start at the `iris-interop` router skill**: it points to the right sibling skill
for each task and enforces the foundational rule that you design the **message
class first**, before BS/BP/BO.

Prefer not to install as a plugin? Clone the repo and open it as a project —
Claude discovers the skills under `skills/` and the examples under
`Mejores_Practicas/`.

## What's inside

### Skills (`skills/`)

| Skill | Use it for |
|---|---|
| `iris-interop` | **Router / index.** Start here; routes to the right skill and enforces messages-first. |
| `iris-interop-messages` | Designing message classes (the foundational building block). |
| `iris-interop-business-services` | Inbound Business Services (adapters, framing, schema category). |
| `iris-interop-business-operations` | Generic (non-SOAP) Business Operations. |
| `iris-interop-soap-bo` | SOAP Business Operations via the SOAP Wizard (and its gotchas). |
| `iris-interop-bpl` | BPL Business Processes and routing rules. |
| `iris-interop-transformations` | DTL data transformations, subtransforms, util functions. |
| `iris-interop-hl7-schemas` | Custom HL7 v2.x schemas — Z-segments, custom structures. |
| `iris-interop-lookup-tables` | Lookup tables — code maps, normalization, CSV sources. |
| `iris-interop-fhir` | FHIR endpoints — Façade vs Repository. |
| `iris-interop-dicom` | DICOM — C-STORE, MWL, Q/R, STOW-RS, DICOM↔HL7/FHIR. |
| `iris-interop-alerting` | The alert circuit — `Ens.Alert` routing + dedup. |
| `iris-interop-security` | Securing endpoints — SAML, OAuth 2.0, TLS/SSL. |
| `iris-interop-production-lifecycle` | The production class — items, settings, deploy, restart. |
| `iris-interop-message-search-debug` | Message search, Visual Trace, the Event Log. |
| `iris-interop-tdd` | TDD-first workflow (companion skill — load it alongside the others). |
| `iris-interop-unit-tests` | `%UnitTest` framework reference. |

### Best practices & worked examples (`Mejores_Practicas/`)

- `BestPractices_Ensemble_IRIS.md` — a synthesis of interoperability patterns,
  each tagged with a **Validity** and **Severity**.
- `examples/` — standalone, runnable code artefacts (`.cls` / `.xml` / `.sh`)
  for the trickier patterns, indexed by rule in `examples/README.md`. Several
  skills cite these as concrete worked examples.
- `external/workshop-iris-dicom-interop/` — a vendored MIT snapshot of the
  InterSystems Iberia DICOM-interop workshop, used by `iris-interop-dicom`.

All customer-identifying provenance has been removed from this public edition;
the patterns are vendor-neutral.

## License

MIT — see [`LICENSE`](LICENSE). The vendored DICOM snapshot keeps its own MIT
license under `Mejores_Practicas/external/workshop-iris-dicom-interop/LICENSE`.
