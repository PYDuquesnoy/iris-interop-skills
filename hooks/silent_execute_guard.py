#!/usr/bin/env python3
"""PostToolUse guard for iris_execute (iris-interop-skills).

If the call "succeeded" but produced no captured output, surface a note: in HTTP
CodeMode only what the code Writes to the device is returned; side-effecting ops must
be wrapped as a [SqlProc] and SELECTed, or verified with a query. Advisory only.
Reads the PostToolUse JSON on stdin; defensive about field names across CC versions.
"""
import sys, json


def payload(r):
    if isinstance(r, str):
        try:
            return json.loads(r)
        except Exception:
            return {"output": r}
    if isinstance(r, list):  # content blocks
        for b in r:
            if isinstance(b, dict) and isinstance(b.get("text"), str):
                try:
                    return json.loads(b["text"])
                except Exception:
                    pass
        return {}
    return r if isinstance(r, dict) else {}


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    resp = data.get("tool_response", data.get("tool_output", {}))
    p = payload(resp)
    out = p.get("output", None)
    success = p.get("success", None)
    no_output = bool(p.get("no_output", False))
    empty = out is not None and str(out).strip() == ""
    if (empty or no_output) and success in (True, None):
        msg = (
            "iris_execute returned no captured output. In HTTP CodeMode only what your "
            "code Writes to the current device is returned — Quit/Return values are NOT "
            "captured. If you expected a value, use `write <expr>,!`. If this was a "
            "side-effecting call (LoadDir/compile/%Save/StartProduction), wrap it as a "
            "[SqlProc] and SELECT it, or verify the effect with iris_query."
        )
        print(json.dumps({"hookSpecificOutput": {
            "hookEventName": "PostToolUse", "additionalContext": msg}}))


if __name__ == "__main__":
    main()
