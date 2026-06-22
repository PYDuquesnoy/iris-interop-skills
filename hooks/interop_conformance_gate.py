#!/usr/bin/env python3
"""PreToolUse conformance GATE for iris_doc / iris_compile / iris_execute (iris-interop-skills).

Unlike the PostToolUse advisories (which a weak model ignores), this BLOCKS the write/compile
when a class violates a hard, unambiguous iris-interop convention, forcing a fix before the
class lands. It denies only high-confidence violations (no false positives on ordinary code):

  1. Non-standard package "type" segment in the class name — the convention is
     <Package>.<Tipo>.<Name> with Tipo in BS/BP/BO/DT/RUL/MSG. A class named `.Operation.`,
     `.Service.`, `.Process.`, `.Transform.` or `.Message.` is the wrong form of a known type.
  2. A class named like a Business Service/Operation that `Extends` an *InboundAdapter /
     *OutboundAdapter directly — a BS/BO must Extend Ens.BusinessService / Ens.BusinessOperation
     and declare the adapter via `Parameter ADAPTER`. (A genuine custom adapter, not named
     .BS./.BO./.Service./.Operation., is left alone.)
  3. Loading/compiling/importing classes through `iris_execute` ($SYSTEM.OBJ.Load /
     $SYSTEM.OBJ.Import / $SYSTEM.OBJ.Compile) — this bypasses the iris_doc/iris_compile path
     AND checks 1-2 above. Source must be written with iris_doc(mode=put) and compiled with
     iris_compile. (Deleting/exporting via iris_execute — Delete/DeletePackage/Export — is fine.)

Everything else is allowed (no output = allow). Deny is emitted as a PreToolUse permissionDecision.
"""
import sys, json, re

# wrong name segment -> correct Tipo abbreviation
NONSTD = {
    "Operation": "BO", "BusinessOperation": "BO",
    "Service": "BS", "BusinessService": "BS",
    "Process": "BP", "BusinessProcess": "BP",
    "Transform": "DT", "Transformation": "DT", "Transformations": "DT",
    "Message": "MSG", "Messages": "MSG",
}
BS_BO_SEGS = {"BS", "BO", "Service", "Operation", "BusinessService", "BusinessOperation"}

# Class load/compile/import driven through iris_execute instead of iris_doc/iris_compile.
# Matches both `$SYSTEM.OBJ.Load(` and the `##class(%SYSTEM.OBJ).Load(` form (optional `)`),
# for Load*/Import*/Compile* only — Delete/DeletePackage/Export are intentionally NOT matched.
OBJ_BYPASS = re.compile(r"(?i)SYSTEM\.OBJ\)?\.(Load|Import|Compile)")


def deny(reason):
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}))
    sys.exit(0)


def collect_names(ti):
    names = []
    for k in ("name", "document"):
        v = ti.get(k)
        if isinstance(v, str) and v:
            names.append(v)
    for k in ("names", "targets", "documents"):
        v = ti.get(k)
        if isinstance(v, list):
            names += [x for x in v if isinstance(x, str)]
    return names


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return  # allow on parse failure — never block legitimate work on a hook bug
    ti = data.get("tool_input", {}) or {}
    names = collect_names(ti)
    content = ti.get("content") if isinstance(ti.get("content"), str) else ""

    # (3) iris_execute used to load/compile/import classes — bypasses iris_doc/iris_compile + this gate.
    code = ti.get("code") if isinstance(ti.get("code"), str) else ""
    if code:
        m = OBJ_BYPASS.search(code)
        if m:
            deny(
                "Loading/compiling classes through iris_execute (matched '%s') bypasses the MCP's "
                "iris_doc/iris_compile path and this conformance gate. Write source with "
                "iris_doc(mode=put) and compile with iris_compile — never $SYSTEM.OBJ.Load / "
                "$SYSTEM.OBJ.Import / $SYSTEM.OBJ.Compile from iris_execute. "
                "(Deleting/exporting via iris_execute is fine.) "
                "Load Skill(iris-interop-skills:production-lifecycle) for the proper deploy path."
                % m.group(0)
            )

    for nm in names:
        base = nm[:-4] if nm.lower().endswith(".cls") else nm
        # only class docs (skip .mac/.inc/.hl7/etc. and non-dotted names)
        if "." not in base or nm.lower().rsplit(".", 1)[-1] in ("mac", "inc", "int", "hl7", "txt"):
            continue
        segs = base.split(".")
        type_segs = segs[1:-1] if len(segs) > 2 else []
        for seg in type_segs:
            if seg in NONSTD:
                deny(
                    "Naming convention: '%s' uses the non-standard package segment '.%s.'. "
                    "iris-interop uses <Package>.<Tipo>.<Name> with Tipo in BS/BP/BO/DT/RUL/MSG — "
                    "rename '.%s.' to '.%s.' and retry. Load Skill(iris-interop-skills:component-map) "
                    "for the task->component->type map." % (nm, seg, seg, NONSTD[seg])
                )

    if content:
        m = re.search(r"Extends\s+([A-Za-z0-9_.%]*(?:Inbound|Outbound)Adapter)\b", content)
        if m:
            looks_bs_bo = any(s in BS_BO_SEGS for nm in names for s in nm.split("."))
            if looks_bs_bo:
                adapter = m.group(1)
                deny(
                    "A Business Service/Operation must Extend Ens.BusinessService / Ens.BusinessOperation "
                    "and declare its adapter as `Parameter ADAPTER = \"%s\";` — not Extend the adapter "
                    "(%s) directly (that yields an empty, non-functional component). Fix the superclass + "
                    "ADAPTER parameter and retry. See Skill(iris-interop-skills:business-services) / "
                    ":business-operations." % (adapter, adapter)
                )
    # no output -> allow


if __name__ == "__main__":
    main()
