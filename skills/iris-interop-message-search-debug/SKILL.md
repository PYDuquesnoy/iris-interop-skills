---
name: iris-interop-message-search-debug
description: Use when searching messages, inspecting Visual Trace, reading the Event Log, resending failed messages, debugging an IRIS Interoperability flow, or live-testing components from the Management Portal Test page. For automated unit tests, see iris-interop-unit-tests instead. Triggers: buscar mensajes, message viewer, visual trace, event log, debug, depurar, reenviar mensaje, message search, test component, probar componente.
---

# Message Search & Debug

Operational troubleshooting on an IRIS Interop production. Four tools cover 95% of the work (Message Viewer, Visual Trace, Event Log, Production Status); the remaining 5% is per-BO SOAP tracing, retention/purge tuning, and bulk-resend recipes.

## When to use this skill

The user is troubleshooting: a message didn't arrive, a transformation produced wrong output, a BO is red, the Event Log is full of warnings, etc. **Or** the user wants to manually test a single component live (Management Portal "Test" link on a BS/BO/BP) without writing automated tests. For automated unit tests, see `iris-interop-unit-tests` instead.

## The four tools (and when to use which)

| Tool | Best for |
|---|---|
| **Message Viewer** | Find a specific message by ID, time, source, target, or property. Filter by status (completed/error). Browse the message body. |
| **Visual Trace** | See the full path of a single message: which BS received it, which BP routed it, which BO sent it, with timestamps and the body at each step. Best for "where did it go wrong" diagnosis. |
| **Event Log** | Component-level events (start/stop/error/warning/info). Best for "is the BS even running" and seeing OnInit failures. |
| **Production Status page** | Per-component live status (queue depth, last-error, last-activity). Quick health check. |

Heuristic: start at the Production Status page (red items?). Follow up in Event Log for component-level errors. Use Visual Trace once you've narrowed to a specific message.

## Searching by message body content

Searchable when:
- The message class is `%Persistent` with the right indexes (see `iris-interop-messages`).
- Or the message is HL7 — built-in indexed fields (MSH:10 control ID, sender, etc.) are searchable.

Not efficiently searchable when:
- The message body is in `Ens.MessageBodyD` without a typed class (full-table-scan territory).
- Hence the importance of `%Persistent` + indexes during message design.

## Resending

From the Message Viewer, a message can be **resent** to its original target or to a new target. Useful after a fix on a downstream system. Resend creates a new session — the old session stays as an audit trail.

For bulk resends (a batch failed during an outage), filter Message Viewer to the affected window + status `Error`, select all, resend. Before bulk-resending: verify **idempotency** on the downstream BO. A non-idempotent BO will create duplicates — fix that first or use a manual loop with deduplication logic in the BP.

## Per-BO SOAP tracing

The global `^ISCSOAP("Log")` toggle traces all SOAP traffic for the namespace, mixing every BO's calls into one log file. Useless on a production with multiple SOAP integrations.

**Better:** per-BO SOAP tracing via a customer-internal copy of `%SOAP.WebClient`:

1. Copy `%SOAP.WebClient` to a customer namespace (e.g. `Alt.SOAP.WebClient`) — `Alt` is the canonical reserved package for patched system classes (xref `iris-interop` §1.2).
2. Change the generated SOAP proxy's superclass from `%SOAP.WebClient` to `Alt.SOAP.WebClient`.
3. Add a `SoapLogFile` setting on each BO; toggle the global only inside that BO's `OnMessage`:

```objectscript
Property SoapLogFile As %String(MAXLEN="512") [ InitialExpression = "" ];
Parameter SETTINGS = "<...>,SoapLogFile";

Method OnMessage(...) {
    If (..SoapLogFile'="") {
        set ^ISCSOAP("Log")="ios"
        set ^ISCSOAP("LogFile")=..SoapLogFile
    }
    // invoke proxy...
    If (..SoapLogFile'="") { set ^ISCSOAP("Log")="" }
}
```

Each BO writes to its own log file path, settable from the Portal at runtime — no recompile to turn tracing on/off.

**Caveat:** `^ISCSOAP` is process-scoped, so heavy multi-process scenarios can still cross-pollute. Treat as a debug aid, not always-on tracing. Disable the SoapLogFile setting once the issue is diagnosed.

Worked example: `${CLAUDE_PLUGIN_ROOT}/Mejores_Practicas/examples/ch06_adapters/alt-soap-webclient-tracing.cls`.

## Retention and purge

Persistent messages and message-body tables grow unbounded. Without a purge task scheduled, `Ens.MessageHeader` and every custom-message-class table accumulate forever.

Add `Ens.Util.Tasks.Purge` to the production at creation time, scheduled daily. Set `NumDaysToKeep` per the customer's retention policy:

- **30 days** — typical default for development environments and low-criticality flows.
- **90 days** — common for production where operational lookback is the only requirement.
- **Longer** — only if a regulatory or contractual retention requirement applies, in which case the messages probably belong in a separate audit store, not in `Ens.MessageHeader`.

The purge task removes both `Ens.MessageHeader` rows and the corresponding message-body table rows. Auditing an existing production, flag the absence of the purge task as a gap (xref `iris-interop-alerting` baseline checklist).

Verify purge actually runs: Management Portal → Interoperability → Manage → System Tasks → check the last-run timestamp and any errors.

## What this skill does NOT yet do

- Auto-correlate a stack of related messages across multiple sessions.
- Generate Message Viewer queries from a plain-English search description.
- Customer-specific retention policy advice (depends on contract; the policy values above are starting defaults).

## Pitfalls to surface

- Searching by body content on a message that's not `%Persistent` → very slow.
- Confusing **Session ID** with **Message ID** — a session is the whole flow, a message is one hop.
- Resending a message that mutates external state without the destination expecting a duplicate → check idempotency first.
- **Bulk-resending without dedup** — a 200-row failure window resent against a non-idempotent BO creates 200 duplicates downstream.
- **Leaving `^ISCSOAP("Log")` enabled namespace-wide** — log file grows fast, mixes all BO traffic, disk fills. Per-BO `SoapLogFile` only.
- **No purge task** → tables grow forever; eventually the namespace becomes slow and large backups become unwieldy.

## See also

- `iris-interop-messages` — design messages so search and trace work well later
- `iris-interop-production-lifecycle` — Production Status page is part of the lifecycle UI; purge task lives there too
- `iris-interop-unit-tests` — for automated, repeatable test coverage (vs ad-hoc Test pages)
- `iris-interop-alerting` — `Ens.Util.Tasks.Purge` is part of the baseline production checklist
- `iris-interop-soap-bo` — generated SOAP client patches and customisation
