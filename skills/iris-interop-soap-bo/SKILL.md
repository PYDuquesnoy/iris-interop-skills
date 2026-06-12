---
name: iris-interop-soap-bo
description: Use when building SOAP Business Operations using the IRIS SOAP Wizard — generating BO and message classes from a WSDL, choosing %SerialObject vs %Persistent for payloads, adding delete triggers, handling recursive XML CDA payloads. Triggers: SOAP, SOAP wizard, WSDL, web service, CDA, soap business operation, generar desde WSDL.
---

# SOAP Business Operations — Wizard-driven

For SOAP destinations, IRIS provides a **SOAP Wizard** that generates a Business Operation class plus request/response message classes from a WSDL. This is almost always the right starting point — hand-rolling SOAP serialization in IRIS is rarely worth the effort.

## When to use this skill

The user wants to call a SOAP web service from IRIS Interoperability, has a WSDL (URL or file), and needs the BO class + message types to wire into a production.

## How to invoke the wizard

Management Portal → **Interoperability → Build → SOAP Wizard** (or "Web Service Client Wizard" in some versions).

1. Provide the WSDL (URL or uploaded file).
2. Choose the package name where generated classes will land (e.g. `MyApp.SOAP.WeatherService`).
3. Confirm operation list — wizard generates one method per WSDL operation.
4. Select Business Operation generation (vs. plain web client) — yes for productions.

Output:
- A BO class extending `Ens.BusinessOperation` with one method per WSDL operation, plus `MessageMap` dispatch.
- One request class and one response class per operation, plus shared type classes.

## Storage decision: %SerialObject vs %Persistent for payloads

The wizard generates payload classes (the WSDL types). By default these are `%SerialObject` — embedded inside the carrying request/response, no separate storage. **Change to `%Persistent` when:**

| Symptom / situation | Use %Persistent + delete trigger |
|---|---|
| Payload contains recursive structures (e.g. CDA `<section>` containing `<section>` containing `<section>`) | YES |
| Payload is large (>100KB serialized) and you'll be retaining many | YES |
| You want to query message bodies by property in `iris-interop-message-search-debug` | YES |
| Simple flat payload, low volume, no recursion | NO — `%SerialObject` is fine |

### Why the recursion case matters

`%SerialObject` serializes inline. For a deeply recursive structure (CDA documents are the worst offender — sections containing sections, entries containing components containing entries), the serialized form blows up `Ens.MessageBodyD` and inflates retention storage in ways that don't free cleanly. Switching the recursive payload class to `%Persistent` gives each instance its own table and storage; the parent message references them by ID.

### The delete trigger

When a payload class is `%Persistent`, it has a separate row from its carrier. When the carrier message is purged (via Ens purge schedules), the payload **does not auto-delete** — you'll leak rows forever. Add a delete trigger:

```objectscript
Trigger DeleteCascade [ Event = DELETE, Foreach = row/object ]
{
    Do ##class(MyApp.SOAP.PayloadType).%DeleteId({ID})
}
```

Or, equivalently, override `%OnDelete` on the carrier to clean up the payload references explicitly. The wizard does NOT generate this for you — you have to add it after switching to `%Persistent`.

## Properties on the carrier vs the payload

Add business properties to the **payload class**, not the wizard-generated carrier. The wizard regenerates carriers when you re-import a WSDL — anything on the carrier is overwritten. Payload classes are also regenerated, but the recursion you're guarding against is the persistence pattern, not custom properties; if you need custom properties, subclass the payload.

## WSDL gotchas — patches to apply on nearly every vendor WSDL

When you import a vendor WSDL, the wizard-generated classes almost always need at least one of these patches. None of them are bugs in IRIS per se — they're vendor-specific deviations from the SOAP standard that the wizard reproduces faithfully and the receiver then rejects.

The wizard-generated classes **are meant to be edited**. Document every patch you apply (header comment with a date tag like `///PYD20260513:` on each modified line) so the next regeneration of the WSDL can re-apply them by greppable diff.

### `wsp:PolicyReference` compile failure (#6447)

**Symptom**: the generated `*HTTPPortConfig` class fails to compile with `ERROR #6447: Unexpected element wsp:PolicyReference in WS-Policy namespace inside %SOAP.Configuration XData block`.

**Fix** — any of:

- Add `Parameter REPORTANYERROR = 0;` to the offending class and rename the `…Config` class to `…ConfigBACKUP`.
- Strip the `<wsp:PolicyReference/>` block from the WSDL before regenerating.
- Delete the generated `XData OnConfigurationCompile` block.

The WS-Policy assertion is not used at runtime by the IRIS client — the actual TLS / signing policy is configured separately on the BO (SSL config setting, credentials, etc.). The XData block is dead weight that happens to break compilation.

Worked example: `${CLAUDE_PLUGIN_ROOT}/Mejores_Practicas/examples/ch06_adapters/soap-wsdl-policyreference-fix.cls`.

### Vendor rejects `xsi:type` attributes

Even when types match the schema, some vendor SOAP servers (notably SAP and certain Spanish public-sector services) return errors when the request contains `xsi:type` attributes on element bodies.

**Fix**: `Parameter OUTPUTTYPEATTRIBUTE = 0;` on the generated SOAP client class. See `iris-interop-messages` for the same setting in the XML-projection context.

Worked example: `${CLAUDE_PLUGIN_ROOT}/Mejores_Practicas/examples/ch06_adapters/soap-xsi-type-suppress.cls`.

### Drop `REQUIRED=1` flags on generated properties

Some vendor services accept SOAP messages with fewer fields than the WSDL declares as required. The IRIS-side validation refuses to send because a "required" field is missing — yet the vendor would have accepted the partial message.

**Fix**: drop `[ Required ]` (`REQUIRED=1` in CDL) from the affected generated properties. Document each one in the patch comments.

Worked example: `${CLAUDE_PLUGIN_ROOT}/Mejores_Practicas/examples/ch06_adapters/soap-required-flag-drop.cls`.

### Strongly-typed dates / times — downgrade to `%String`

Where the WSDL declares `xs:date` or `xs:time` and the vendor server cannot actually parse the typed form (despite the WSDL claiming it does), change the generated property type to `%String`.

The transmitted lexical form (`2026-05-13` for date, `14:30:00` for time) is correct regardless — the IRIS-side type was forcing a normalization step the vendor couldn't reverse. With `%String`, the field passes through unchanged.

Worked example: `${CLAUDE_PLUGIN_ROOT}/Mejores_Practicas/examples/ch06_adapters/soap-typed-dates-to-string.cls`.

### `RESPONSENAMESPACE` doesn't match what the vendor actually returns

The WSDL specifies one response namespace; the actual SOAP responses come back with a different one. Strict parsers reject the mismatch.

**Fix**: override `Parameter RESPONSENAMESPACE` on the generated proxy to the actual namespace the vendor returns. **General rule** for any SOAP integration: don't trust the WSDL blindly — capture an actual response (with `iris-interop-message-search-debug` SOAP tracing) and align the generated client to what's on the wire.

Worked example: `${CLAUDE_PLUGIN_ROOT}/Mejores_Practicas/examples/ch06_adapters/soap-response-namespace-override.cls`.

### XML namespace alias must literally be `urn`

Vendor services occasionally return errors unless the SOAP envelope's namespace prefix is literally `urn` (not the default `s` or `soap` the wizard emits).

**Fix**: instantiate the SOAP client manually so the namespace prefix can be set explicitly before invocation. Same instantiation pattern as the SAML custom-header example (see `iris-interop-security §11.3`).

### Generated classes ARE meant to be edited

The naming convention's reserved `<Pkg>.<SubPkg>.WSC<Name>` sub-package (see `iris-interop` §1.1) is partly motivated by these patches. Generated SOAP/XSD classes need to be **regeneratable in isolation** (delete the sub-package, re-run the wizard, re-apply patches) AND every patch needs to be applied each time.

Document every patch in the class header with a stable tag (e.g. `///PYD20260513:` prefix on each modified line) — a grep across the regenerated classes finds the patches to re-apply by tag, not by line position.

## SOAP tracing per BO

For diagnosing wire-level issues on a SOAP BO, use a per-BO `SoapLogFile` setting rather than the namespace-wide `^ISCSOAP("Log")` toggle. Each BO writes to its own log file path, settable at runtime from the portal — covered in `iris-interop-message-search-debug §6.2`.

## Canonical pattern — calling the SOAP BO

```objectscript
// In a BPL or a calling method
Set tReq = ##class(MyApp.SOAP.WeatherService.GetForecastRequest).%New()
Set tReq.City = "Madrid"
Set tSC = ..SendRequestSync("BO_WeatherService", tReq, .tResp)
If $$$ISERR(tSC) Quit tSC
Set tForecast = tResp.GetForecastResult
```

Sync vs Async: SOAP calls are usually synchronous (you want the response). But if the BP doesn't need the response immediately, Async + a callback pattern keeps pool slots free.

## Common pitfalls

- **Treating `%SerialObject` payloads as universally fine** → recursive CDA payloads bloat or break.
- **Forgetting the delete trigger** when switching to `%Persistent` → orphaned payload rows, eternal storage growth.
- **Adding properties on the wizard-generated carrier** → overwritten on next WSDL re-import.
- **No timeout on the SOAP outbound** → a hung remote endpoint blocks the BO pool indefinitely.
- **Hardcoded WSDL URL in code** → use a setting (`SOAPClient.Endpoint` or similar) so DEV/TEST/PROD differ.
- **Re-running the SOAP Wizard over modified generated classes** → wipes your changes. If you've customized, either don't re-run or use a subclass for customizations.

## Testing / how to verify

1. Compile the generated classes via iris-dev MCP. WSDL ambiguities surface as compile errors.
2. **Inside the wizard's Test page** → invoke each operation with sample input. Confirms the BO can reach the endpoint and parse the response.
3. From a unit test (`iris-interop-unit-tests`), invoke the BO method directly with a constructed request. Stub the endpoint with a local mock if the real endpoint isn't reachable.
4. Use `iris-interop-message-search-debug` to confirm Visual Trace shows the request → response cycle correctly when the BO is called from a BP.

## Alternative path: HTTP outbound + hand-crafted envelope

The SOAP Wizard runs in the **Management Portal UI** — it is **not invocable** from the IRIS REST API or from the MCP tooling. `%SOAP.WSDL.Reader.Process()` (the underlying class) is similarly fiddly and undocumented across versions. If you're driving IRIS from outside the portal (MCP-only workflow, headless CI, programmatic class generation), don't fight the Wizard — **use `EnsLib.HTTP.OutboundAdapter` + a hand-crafted SOAP envelope** (covered in `iris-interop-business-operations`).

Trade-offs:

| | SOAP Wizard | HTTP-manual envelope |
|---|---|---|
| Strongly-typed request/response classes | ✓ generated | ✗ build XML/parse XML by hand |
| Visibility into wire | poor (`%SOAP.WebClient` hides everything) | full (you write the bytes) |
| Debuggability when remote returns 4xx/5xx fault | hard (`<ZSOAP> 64` errors with no detail) | easy (read response body, see fault XML) |
| Requires MGT Portal access at build time | yes | no |
| Maintenance burden when WSDL evolves | re-run Wizard, may overwrite customizations | hand-edit the envelope |

Use the Wizard for stable, well-defined services consumed long-term. Use HTTP-manual for: workshops, MCP-driven development, one-off integrations, services with quirky WSDL that the Wizard chokes on, or any case where `%SOAP.WebClient` gives `<ZSOAP> 64` and you can't tell why. Document the choice as a friction-log entry — the IRIS SOAP stack's debug story is not great and "use the Wizard" isn't always actionable.

## Server-side: hosting a SOAP service in an IRIS namespace

When you're on the **other side** — exposing a SOAP service that an external client (or a sibling IRIS namespace) will call — `%SOAP.WebService`:

- Web app config (Security.Applications): `AutheEnabled=96` (Password + Kerberos, accepts HTTP Basic) — **not** `4=Password` per the docs, which doesn't accept Basic in IRIS 2026.1. See `iris-interop-business-services` for the full table.
- The authenticated user must have **read access to the system globals** the SOAP framework touches (`^ISCSOAP`). Granting `%All` to the service user is the simplest workshop pattern; production should grant `%DB_<TARGET>_DATA:RW` plus enough on `IRISSYS` to read `^ISCSOAP`. The error `<PROTECT> OnPage+9^%SOAP.WebService.1 ^ISCSOAP("LogMaxFileSize")` is the symptom of missing this read access.
- `Parameter SERVICENAME` and `Parameter NAMESPACE` (the XML target namespace) drive the WSDL. They must match what clients expect from `<service name>` and `targetNamespace` respectively.

## When NOT to use this skill — fall back to docs

- REST endpoints (`EnsLib.REST.OutboundAdapter`) → see `iris-interop-business-operations`.
- WS-Security / WS-Addressing customization beyond what the wizard supports → docs.
- WCF / `.NET`-specific SOAP quirks → not workshop-validated.

## See also

- `iris-interop-messages` — payload class storage decisions live here too; SOAP envelopes carrying HL7 / CDA
- `iris-interop-business-operations` — generic BO patterns (non-SOAP destinations); HTTP-manual envelope fallback; settings checklist
- `iris-interop-unit-tests` — testing the generated BO methods
- `iris-interop-message-search-debug` — verifying end-to-end SOAP calls; per-BO SOAP tracing
- `iris-interop-security` — attaching SAML / WS-Security custom headers to the generated proxy
- `iris-interop` — generated-class sub-package naming convention (§1.1, `WSC<Name>` pattern)
