# shellcheck shell=bash
# Shared helpers. Bash 3.2 compatible (macOS /bin/bash): no associative arrays,
# no mapfile, no ${var,,}.

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../config.env
. "$KIT_DIR/config.env"

# Sandbox locations (same values env.sh exports for interactive shells), set
# here so every step works even before env.sh exists.
export IBX_HOME WORKSPACE
export RUSTUP_HOME="$IBX_HOME/rustup" CARGO_HOME="$IBX_HOME/cargo"
export UV_PYTHON_INSTALL_DIR="$IBX_HOME/uv/python" UV_TOOL_DIR="$IBX_HOME/uv/tools"
export UV_TOOL_BIN_DIR="$IBX_HOME/bin" UV_PYTHON_BIN_DIR="$IBX_HOME/bin" UV_CACHE_DIR="$IBX_HOME/cache/uv"
export FNM_DIR="$IBX_HOME/fnm" CODEX_HOME="$IBX_HOME/codex"
export npm_config_cache="$IBX_HOME/cache/npm"
export PUPPETEER_CACHE_DIR="$IBX_HOME/cache/puppeteer" PLAYWRIGHT_BROWSERS_PATH="$IBX_HOME/cache/ms-playwright"

MANIFEST="$IBX_HOME/manifest"
RC_BEGIN="# >>> interview-env >>>"
RC_END="# <<< interview-env <<<"
DRY_RUN="${DRY_RUN:-0}"
ASSUME_YES="${ASSUME_YES:-0}"

if [ -t 1 ]; then
  C_B=$'\033[1m'; C_G=$'\033[32m'; C_Y=$'\033[33m'; C_R=$'\033[31m'; C_D=$'\033[2m'; C_0=$'\033[0m'
else
  C_B=""; C_G=""; C_Y=""; C_R=""; C_D=""; C_0=""
fi

step()  { printf '\n%s==> %s%s\n' "$C_B" "$*" "$C_0"; }
info()  { printf '    %s\n' "$*"; }
ok()    { printf '    %s✓%s %s\n' "$C_G" "$C_0" "$*"; }
warn()  { printf '    %s!%s %s\n' "$C_Y" "$C_0" "$*" >&2; }
die()   { printf '%sERROR:%s %s\n' "$C_R" "$C_0" "$*" >&2; exit 1; }
have()  { command -v "$1" >/dev/null 2>&1; }

# run <cmd...> — executes, or prints in dry-run mode.
run() {
  if [ "$DRY_RUN" = "1" ]; then printf '    %s[dry-run]%s %s\n' "$C_D" "$C_0" "$*"; return 0; fi
  "$@"
}

# run_sh "<shell pipeline>" — for curl | sh style installers.
run_sh() {
  if [ "$DRY_RUN" = "1" ]; then printf '    %s[dry-run]%s %s\n' "$C_D" "$C_0" "$1"; return 0; fi
  /bin/bash -c "$1"
}

confirm() {
  [ "$ASSUME_YES" = "1" ] && return 0
  local reply
  printf '%s [y/N] ' "$1"
  read -r reply </dev/tty || return 1
  case "$reply" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

# --- manifest: one line per thing we created, "<kind>:<value>" ---------------
record() {
  [ "$DRY_RUN" = "1" ] && return 0
  mkdir -p "$IBX_HOME"
  touch "$MANIFEST"
  grep -qxF "$1" "$MANIFEST" 2>/dev/null || printf '%s\n' "$1" >> "$MANIFEST"
}
recorded() { [ -f "$MANIFEST" ] && grep -qxF "$1" "$MANIFEST"; }

# Record a path for removal only if it does not exist yet (i.e. we create it).
claim_path() {
  if [ ! -e "$1" ] && [ ! -L "$1" ]; then record "path:$1"; fi
}

brew_bin() {
  if [ -x /opt/homebrew/bin/brew ]; then echo /opt/homebrew/bin/brew
  elif [ -x /usr/local/bin/brew ]; then echo /usr/local/bin/brew
  elif have brew; then command -v brew
  fi
}

# Load the sandbox environment into the current (script) shell.
load_env() {
  # shellcheck disable=SC1091
  [ -f "$IBX_HOME/env.sh" ] && . "$IBX_HOME/env.sh"
  return 0
}
