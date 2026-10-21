# shellcheck shell=bash
# Xcode Command Line Tools + Homebrew + small CLI tools.

step "Xcode Command Line Tools & Homebrew"

if ! xcode-select -p >/dev/null 2>&1; then
  record "system:xcode-clt"
  info "Command Line Tools missing; the Homebrew installer will install them."
fi

BREW="$(brew_bin)"
if [ -z "$BREW" ]; then
  info "Installing Homebrew (asks for your password once)…"
  run sudo -v
  # Keep sudo alive while the Command Line Tools download (can take >5 min).
  if [ "$DRY_RUN" != "1" ]; then
    ( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done ) 2>/dev/null &
  fi
  run_sh 'NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  record "system:homebrew"
  BREW="$(brew_bin)"
  [ -n "$BREW" ] || [ "$DRY_RUN" = "1" ] || die "Homebrew install failed."
  BREW="${BREW:-/opt/homebrew/bin/brew}"
else
  ok "Homebrew present at $BREW"
fi

# Still no CLT (Homebrew pre-existed but CLT was removed)? Trigger the GUI installer.
if ! xcode-select -p >/dev/null 2>&1 && [ "$DRY_RUN" != "1" ]; then
  xcode-select --install || true
  die "Finish the Command Line Tools dialog, then re-run ./bootstrap.sh"
fi

load_env
export HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_ENV_HINTS=1

step "CLI tools (Homebrew)"
for f in $BREW_FORMULAE; do
  if [ "$DRY_RUN" != "1" ] && "$BREW" list --formula "$f" >/dev/null 2>&1; then
    ok "$f (already installed, left alone)"
  else
    run "$BREW" install --quiet "$f" && record "brew:$f" && ok "$f"
  fi
done

for c in $BREW_CASKS; do
  if [ "$DRY_RUN" != "1" ] && "$BREW" list --cask "$c" >/dev/null 2>&1; then
    ok "$c (already installed, left alone)"
  else
    run "$BREW" install --cask "$c" && record "cask:$c" && ok "$c"
  fi
done
