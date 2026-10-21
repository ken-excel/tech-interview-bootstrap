#!/bin/bash
# PostToolUse hook (Edit|Write|MultiEdit): format the file Claude just changed.
# Input: hook JSON on stdin with .tool_input.file_path. Never blocks (exit 0).
input="$(cat)"
if command -v jq >/dev/null 2>&1; then
  f="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
else
  f="$(printf '%s' "$input" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' 2>/dev/null)"
fi
[ -n "$f" ] && [ -f "$f" ] || exit 0

case "$f" in
  *.rs) command -v rustfmt >/dev/null && rustfmt --edition 2024 "$f" 2>/dev/null ;;
  *.py) command -v ruff    >/dev/null && ruff format --quiet "$f" 2>/dev/null ;;
esac
exit 0
