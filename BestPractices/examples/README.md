# Code examples — rule → file index

This directory hosts standalone code artefacts referenced from
`../BestPractices_Interop_IRIS.md`. The deliverable is the canonical source;
each file here is a verbatim lift (or faithful reconstruction) of a "tricky"
pattern that needs concrete code to reproduce.

Every file carries a header block with:
- **Rule** — the §X.Y reference in the deliverable
- **Validity** — copy of the deliverable's validity tag

If a rule's pattern is fully canonicalised in a public InterSystems-Iberia
GitHub repo, the example is **not** lifted here — see `external-repos.md`.

## Rule → file

| Chapter | Rule | File |
|---|---|---|
| §2.3 | HL7 v2 escape special characters when building messages manually | `ch02_hl7v2/hl7v2-escape-functionset.cls` |
| §3.1 | CDA-from-XSD: Persistent + no Relationships + OnDelete Cascade | `ch03_cda/cda-from-xsd-persistence-pattern.cls` |
| §3.2 | Comanda/Resposta inheritance for one-of-N subtypes | `ch03_cda/comanda-resposta-inheritance.cls` |
| §3.4 | SOAP carrying CDA / HL7 as MessageBody | `ch03_cda/soap-messagebody-hl7-proxy.cls` |
| §5.1 | BS that exposes a SOAP service | `ch05_bpl_dtl/soap-business-service.cls` |
| §5.3 | XML projection settings — `XMLIGNORENULL` / `CONTENT` / `OUTPUTTYPEATTRIBUTE` | `ch05_bpl_dtl/xml-projection-settings.cls` |
| §5.4 | ObjectScript try/catch + %Status idiom | `ch05_bpl_dtl/objectscript-trycatch.cls` |
| §5.5 | Async logging via `^IRISTemp.*` + `System.Semaphores` | `ch05_bpl_dtl/async-logger-iristemp-semaphore.cls` |
| §6.1.1 | `wsp:PolicyReference` (#6447) compile fix | `ch06_adapters/soap-wsdl-policyreference-fix.cls` |
| §6.1.2 | Suppress `xsi:type` for vendor SOAP servers | `ch06_adapters/soap-xsi-type-suppress.cls` |
| §6.1.4 | Drop `REQUIRED=1` from generated SOAP type properties | `ch06_adapters/soap-required-flag-drop.cls` |
| §6.1.5 | Downgrade strongly-typed dates/times to `%String` | `ch06_adapters/soap-typed-dates-to-string.cls` |
| §6.1.6 | Override `RESPONSENAMESPACE` to match what the vendor actually returns | `ch06_adapters/soap-response-namespace-override.cls` |
| §6.2 / §12.4 | Per-BO `Alt.SOAP.WebClient` for SOAP tracing | `ch06_adapters/alt-soap-webclient-tracing.cls` |
| §6.6 | Java integration via JavaGateway | `ch06_adapters/javagateway-bo.cls` |
| §7.1 | Canonical Ens.Alert routing circuit (production XML + rule) | `ch07_alerting/alert-circuit-production.xml` |
| §7.2 / §12.5 | Alert deduplication FunctionSet (`AlreadyReportedErr` / `AlreadyReportedPerSession`) | `ch07_alerting/alert-dedup-functionset.cls` |
| §11.3 | SAML 2.0 custom security header on a generated SOAP BO | `ch11_security/saml2-custom-security-header.cls` |
| §11.5 | OAuth 2.0 + LDAP server-side broker | `ch11_security/oauth2-server-validate-ldap.cls.xml` |
| §11.7 | SSL/TLS trusted CA chain build (`openssl s_client -servername`) | `ch11_security/ssl-trusted-ca-chain.sh` |
| §13.7 | Credentials migration — walk `Ens.Config.Credentials`, export, re-import | `ch13_migration/credentials-export-reimport.cls` |

## Rules with public-repo canonical sources

The following deliverable rules are best served by reading the public,
maintained version — no local copy here. See `external-repos.md` for URLs.

| Rule | Why no local copy |
|---|---|
| §2.6 HL7 v2 in XML form | Canonical: `intersystems-ib/Healthcare-HL7-XML` (actively maintained) |
| §11.1 SAML 2.0 charset fix | Canonical: `intersystems-ib/SAML-COS` (built specifically to address the bug) |
| §11.4 SAML 1.1 wrapper for e-prescription | Canonical: `intersystems-ib/SAML11-COS` |
| §9.1 Deployment tool | Canonical: `PYDuquesnoy/IRIS-Interop-Deployment` |

## Rules without code (process / architecture / version-specific)

Several deliverable rules are pure guidance with no code component:
naming convention (§1.1), reserved package names (§1.2), namespace split criteria (§1.3),
configuration-source precedence (§1.4), FHIR Façade architecture (§4.1–4.8),
version-specific notes (§14.*), etc. They are not represented here; read the deliverable directly.

## What's explicitly NOT here (and why)

- **Non-interop chapters removed on 2026-05-13.** The deliverable's original §8 (Performance & sizing), §10 (Mirroring/HA/backups), and most of §13 (generic IRIS migration) were trimmed. The corresponding `examples/ch08_performance/`, `ch10_mirror_backup/`, and parts of `ch13_migration/` were deleted in the same pass. This directory now focuses on **IRIS Interoperability** patterns only.
