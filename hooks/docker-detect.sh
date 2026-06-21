#!/bin/sh
# PostToolUse non-Docker hint (iris-interop-skills, C4) — on a DOCKER_REQUIRED error, advise the
# HTTP path. Thin wrapper so the hook JSON on stdin reaches Python. Resolves the interpreter as
# python3 -> python -> py (Windows has no `python3`); no-op if none is on PATH.
PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || command -v py 2>/dev/null)
[ -n "$PY" ] || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec "$PY" "$DIR/docker_detect.py"
