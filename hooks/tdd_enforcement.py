#!/usr/bin/env python3
"""PostToolUse TDD guard for Write|Edit (iris-interop-skills).

If an interop implementation class (*.BO.* / *.BP.* / *DTL* / *Rule* ending .cls) is
written WITHOUT a sibling *Test* class nearby, remind the model to write the test first
(spec -> test -> red -> implement -> green; tests extend %UnitTest.TestProduction).
Advisory only; filesystem heuristic; never blocks.
"""
import sys, json, os, re, glob


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        return
    ti = data.get("tool_input", {})
    path = ti.get("file_path") or ti.get("path") or ""
    low = path.lower()
    if not low.endswith(".cls"):
        return
    if not re.search(r"\.bo\.|\.bp\.|dtl|rule", low):  # interop component classes only
        return
    base = os.path.basename(path)
    if "test" in base.lower():  # the test itself — fine
        return

    roots = []
    d = os.path.dirname(path)
    if d:
        roots.append(d)
    proj = os.environ.get("CLAUDE_PROJECT_DIR")
    if proj:
        roots.append(proj)

    for r in roots:
        if r and glob.glob(os.path.join(r, "**", "*Test*.cls"), recursive=True):
            return  # a test exists nearby

    msg = (
        "TDD: you just wrote an interop component (" + base + ") but found no sibling "
        "*Test*.cls. Per iris-interop-skills:tdd, write the test FIRST "
        "(spec -> test -> red -> implement -> green). Test classes extend "
        "%UnitTest.TestProduction."
    )
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PostToolUse", "additionalContext": msg}}))


if __name__ == "__main__":
    main()
