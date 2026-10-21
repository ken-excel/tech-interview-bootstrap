#!/bin/bash
# Remove everything tech-interview-bootstrap installed, in one go.
#
#   ./uninstall.sh                 interactive; asks before deleting the workspace
#                                  and before removing Homebrew / Command Line Tools
#   ./uninstall.sh --yes --all     remove everything it created, no questions
#   ./uninstall.sh --keep-workspace  keep ~/interview (your interview notes/code)
#   ./uninstall.sh --dry-run       show what would be removed
#
# Only things recorded in $IBX_HOME/manifest are touched: tools you already had
# before bootstrapping are never removed.
set -uo pipefail

ALL=0; KEEP_WS=0
for a in "$@"; do
  case "$a" in
    --dry-run) export DRY_RUN=1 ;;
    -y|--yes)  export ASSUME_YES=1 ;;
    --all)     ALL=1 ;;
    --keep-workspace) KEEP_WS=1 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $a" >&2; exit 2 ;;
  esac
done

# shellcheck source=lib/common.sh
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

[ -f "$MANIFEST" ] || die "No manifest at $MANIFEST — nothing to uninstall (or IBX_HOME differs)."

entries() { grep "^$1:" "$MANIFEST" | cut -d: -f2- | awk '{a[NR]=$0} END{for(i=NR;i>0;i--)print a[i]}'; }

safe_rm() {
  local p="$1"
  case "$p" in
    "$HOME"/?*) ;;                      # must be strictly inside $HOME
    *) warn "refusing to remove '$p' (outside \$HOME)"; return 1 ;;
  esac
  [ "$p" = "$HOME" ] && { warn "refusing to remove \$HOME"; return 1; }
  if [ -e "$p" ] || [ -L "$p" ]; then run rm -rf "$p" && ok "removed $p"; fi
}

printf '%sUninstalling tech-interview-bootstrap%s\n' "$C_B" "$C_0"
info "manifest: $MANIFEST"
confirm "Proceed?" || { info "Aborted."; exit 0; }

step "Shell rc hooks"
for rc in $(entries rcblock); do
  [ -f "$rc" ] || continue
  if [ "$DRY_RUN" = "1" ]; then info "[dry-run] strip block from $rc"; continue; fi
  tmp="$(mktemp)"
  awk -v b="$RC_BEGIN" -v e="$RC_END" '
    $0==b {skip=1; next} $0==e {skip=0; next} !skip {print}' "$rc" > "$tmp" && cat "$tmp" > "$rc"
  rm -f "$tmp"
  ok "cleaned $rc"
done

step "Credentials"
entries keychain | while IFS= read -r svc; do
  [ -n "$svc" ] || continue
  if [ "$DRY_RUN" = "1" ]; then info "[dry-run] delete keychain item '$svc'"; continue; fi
  n=0
  while security delete-generic-password -s "$svc" >/dev/null 2>&1; do n=$((n+1)); done
  ok "keychain '$svc': removed $n item(s)"
done

REMOVE_BREW=0
if recorded "system:homebrew"; then
  if [ "$ALL" = "1" ] || confirm "Homebrew was installed by this kit. Remove Homebrew entirely?"; then REMOVE_BREW=1; fi
fi

BREW="$(brew_bin)"
if [ -n "$BREW" ] && [ "$REMOVE_BREW" = "0" ]; then
  step "Homebrew packages installed by the kit"
  for c in $(entries cask);  do run "$BREW" uninstall --cask "$c" && ok "cask $c"; done
  for f in $(entries brew);  do
    run "$BREW" uninstall "$f" 2>/dev/null && ok "$f" || warn "$f kept (another formula depends on it)"
  done
  info "tip: 'brew autoremove' cleans now-unused dependencies"
fi

step "Files created outside the sandbox"
entries path | while IFS= read -r p; do
  [ -n "$p" ] && safe_rm "$p"
done
# tidy empty parents we may have created
for d in "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.local/state" "$HOME/.cache" "$HOME/.local"; do
  [ "$DRY_RUN" = "1" ] || rmdir "$d" 2>/dev/null || true
done

step "Workspace"
for ws in $(entries workspace); do
  [ -d "$ws" ] || continue
  # (confirm reads /dev/tty, so this loop must not be fed by a pipe)
  if [ "$KEEP_WS" = "1" ]; then ok "kept $ws (--keep-workspace)"; continue; fi
  if confirm "Delete workspace $ws (your interview code & notes)?"; then safe_rm "$ws"; else ok "kept $ws"; fi
done

step "Sandbox ($IBX_HOME): toolchains, caches, agent config"
# Fix read-only files (Go/npm caches etc.) before removal.
[ "$DRY_RUN" = "1" ] || chmod -R u+w "$IBX_HOME" 2>/dev/null || true
SYS_HB=0; SYS_CLT=0
recorded "system:homebrew" && SYS_HB=1
recorded "system:xcode-clt" && SYS_CLT=1
safe_rm "$IBX_HOME"

if [ "$REMOVE_BREW" = "1" ] && [ "$SYS_HB" = "1" ]; then
  step "Homebrew"
  run_sh 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"'
  [ -d /opt/homebrew ] && run sudo rm -rf /opt/homebrew
  ok "Homebrew removed"
fi

if [ "$SYS_CLT" = "1" ] && [ -d /Library/Developer/CommandLineTools ]; then
  if [ "$ALL" = "1" ] || confirm "Command Line Tools were installed during bootstrap. Remove them?"; then
    step "Xcode Command Line Tools"
    run sudo rm -rf /Library/Developer/CommandLineTools && ok "removed"
  fi
fi

step "Done"
info "Open a new terminal so PATH no longer points at the removed tools."
