#!/bin/sh
# PostToolUse non-Docker hint (iris-interop-skills, C4) — on a DOCKER_REQUIRED error, advise the
# HTTP path. Thin wrapper so the hook JSON on stdin reaches python. Requires python3; no-op without it.
command -v python3 >/dev/null 2>&1 || exit 0
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec python3 "$DIR/docker_detect.py"
