# shellcheck shell=bash
# Python via uv (standalone binary in the sandbox; managed interpreters).

step "Python $PYTHON_VERSION (uv)"

if [ -x "$IBX_HOME/bin/uv" ]; then
  ok "uv present in sandbox"
  run "$IBX_HOME/bin/uv" self update --quiet || true
else
  run_sh "curl -LsSf https://astral.sh/uv/install.sh | \
    env UV_INSTALL_DIR='$IBX_HOME/bin' UV_NO_MODIFY_PATH=1 sh"
fi
load_env

run uv python install "$PYTHON_VERSION"
if [ "$DRY_RUN" != "1" ]; then
  PY_BIN="$(uv python find "$PYTHON_VERSION")"
  ln -sf "$PY_BIN" "$IBX_HOME/bin/python3"
  ln -sf "$PY_BIN" "$IBX_HOME/bin/python"
fi
run uv tool install --quiet ruff || true
[ "$DRY_RUN" = "1" ] || ok "$(uv --version); $("$IBX_HOME/bin/python3" --version)"
