#!/bin/bash
# Render diagrams to diagrams/out/*.svg
#   ./diagrams/render.sh                 all .mmd, .d2 and .dot files
#   ./diagrams/render.sh diagrams/x.d2   just one
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p out

render() {
  local f="$1" base
  base="$(basename "${f%.*}")"
  case "$f" in
    *.mmd) mmdc --quiet -i "$f" -o "out/$base.svg" -b transparent ;;
    *.d2)  d2 --layout=elk "$f" "out/$base.svg" >/dev/null 2>&1 || d2 "$f" "out/$base.svg" >/dev/null ;;
    *.dot) dot -Tsvg "$f" -o "out/$base.svg" ;;
    *) echo "skip $f (unknown type)"; return 0 ;;
  esac
  echo "  ✓ out/$base.svg"
}

if [ $# -gt 0 ]; then
  for f in "$@"; do render "$(cd "$OLDPWD" && realpath "$f")"; done
else
  shopt -s nullglob
  for f in *.mmd *.d2 *.dot; do render "$f"; done
fi
