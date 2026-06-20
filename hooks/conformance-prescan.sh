#!/bin/sh
# PostToolUse conformance pre-scan for Write|Edit (iris-interop-skills) — when an interop
# .cls is written, cheaply screen that file for the mechanically-detectable anti-patterns
# (CR-1/2/4/5/7/10) and, if any match, nudge to run the conformance-reviewer agent. Thin
# wrapper: exec the .py so the hook JSON on stdin reaches python. Requires python3
# (documented in README); degrades to a no-op if python3 is absent. Never blocks.
command -v python3 >/dev/null 2>&1 || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec python3 "$DIR/conformance_prescan.py"
