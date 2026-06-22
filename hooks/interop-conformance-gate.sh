#!/bin/sh
# PreToolUse conformance GATE for iris_doc|iris_compile (iris-interop-skills) — BLOCKS a write/compile
# that violates a hard naming/superclass convention (non-standard .Tipo. segment, or a BS/BO that
# extends the adapter directly), forcing a fix before the class lands. Thin wrapper: exec the .py so
# the hook JSON on stdin reaches Python. Resolves python3 -> python -> py (Windows has no `python3`);
# if no interpreter is on PATH, exit 0 (allow) — never block legitimate work on a missing interpreter.
PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || command -v py 2>/dev/null)
[ -n "$PY" ] || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$PY" "$DIR/interop_conformance_gate.py"
