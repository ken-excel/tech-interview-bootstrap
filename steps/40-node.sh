# shellcheck shell=bash
# Node via fnm (standalone binary in the sandbox) + a few global CLIs.

step "Node $NODE_VERSION (fnm)"

if [ -x "$IBX_HOME/fnm-bin/fnm" ]; then
  ok "fnm present in sandbox"
else
  run_sh "curl -fsSL https://fnm.vercel.app/install | \
    bash -s -- --install-dir '$IBX_HOME/fnm-bin' --skip-shell --force-no-brew"
fi
load_env

# fnm keeps per-shell symlinks outside FNM_DIR; claim them for cleanup.
claim_path "$HOME/.local/state/fnm_multishells"
claim_path "$HOME/Library/Caches/fnm_multishells"

if [ "$NODE_VERSION" = "lts-latest" ]; then
  run fnm install --lts
  run fnm default lts-latest 2>/dev/null || \
    run fnm default "$(fnm list | awk '{print $2}' | grep '^v' | tail -1)"
else
  run fnm install "$NODE_VERSION"
  run fnm default "$NODE_VERSION"
fi
load_env
[ "$DRY_RUN" = "1" ] || ok "node $(node --version), npm $(npm --version)"

step "Global npm CLIs (inside sandboxed Node)"
for p in $NPM_GLOBALS; do
  run npm install -g --no-fund --no-audit --loglevel=error "$p" && ok "$p"
done
