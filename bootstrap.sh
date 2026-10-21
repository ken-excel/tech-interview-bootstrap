#!/bin/bash
# tech-interview-bootstrap — set up a fresh Mac for an AI-assisted tech interview.
#
#   ./bootstrap.sh              full setup (safe to re-run)
#   ./bootstrap.sh --dry-run    print what would happen, change nothing
#   ./bootstrap.sh --only rust  run one step (preflight always runs)
#   ./bootstrap.sh --skip warm  skip a step
#
# Steps: preflight homebrew rust python node agents workspace warm
set -euo pipefail

usage() { sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0; }

ONLY=""; SKIP=""
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) export DRY_RUN=1 ;;
    -y|--yes)  export ASSUME_YES=1 ;;
    --only)    ONLY="$2"; shift ;;
    --skip)    SKIP="$SKIP $2"; shift ;;
    -h|--help) usage ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

# shellcheck source=lib/common.sh
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

if [ "$DRY_RUN" != "1" ]; then
  mkdir -p "$IBX_HOME/logs"
  LOG="$IBX_HOME/logs/bootstrap-$(date +%Y%m%d-%H%M%S).log"
  exec > >(tee -a "$LOG") 2>&1
fi

printf '%stech-interview-bootstrap%s\n' "$C_B" "$C_0"
info "sandbox:   $IBX_HOME"
info "workspace: $WORKSPACE"
[ "$DRY_RUN" = "1" ] && info "mode:      DRY RUN (nothing will change)"

should_run() {
  local name="$1"
  case " $SKIP " in *" $name "*) return 1 ;; esac
  [ -z "$ONLY" ] || [ "$name" = "preflight" ] || [ "$name" = "$ONLY" ]
}

for f in "$KIT_DIR"/steps/[0-9][0-9]-*.sh; do
  name="$(basename "$f" .sh)"; name="${name#[0-9][0-9]-}"
  if should_run "$name"; then
    # shellcheck disable=SC1090
    . "$f"
  fi
done

step "Done"
cat <<EOF
    Next:
      1. Open a NEW terminal (or: source "$IBX_HOME/env.sh")
      2. ibx doctor                 # verify everything
      3. claude    → log in;  codex login
      4. ibx gather                 # agents research tooling + practices into docs/context/
      5. cd "$WORKSPACE" && claude   (or: codex)

    Remove everything later with:  ibx uninstall
EOF
[ "$DRY_RUN" = "1" ] || info "log: $LOG"
