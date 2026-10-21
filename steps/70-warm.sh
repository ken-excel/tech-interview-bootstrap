# shellcheck shell=bash
# Pre-build starters and pre-fetch MCP servers so nothing downloads mid-interview.

[ "$WARM_CACHES" = "1" ] || { info "WARM_CACHES=0; skipping warm-up"; return 0; }
if [ "$DRY_RUN" = "1" ]; then
  step "Warm-up"
  info "[dry-run] build + test poc/rust-api, poc/py-scripts, poc/web; render diagrams; cache MCP packages"
  return 0
fi

step "Warm-up: build + test every starter"
W="$WORKSPACE"
( cd "$W/poc/rust-api"   && run cargo build --quiet && run cargo test --quiet ) && ok "rust-api builds, tests pass"      || warn "rust-api warm-up failed"
( cd "$W/poc/py-scripts" && run uv sync --quiet && run uv run --quiet pytest -q ) && ok "py-scripts syncs, tests pass" || warn "py-scripts warm-up failed"
( cd "$W/poc/web"        && run npm install --no-fund --no-audit --loglevel=error && run npm test --silent && run npm run build --silent ) \
  && ok "web installs, tests pass, builds" || warn "web warm-up failed"

step "Warm-up: diagrams + charts"
( cd "$W" && run ./diagrams/render.sh ) && ok "diagrams render (mermaid + d2)" || warn "diagram render failed"
( cd "$W" && run uv run --quiet viz/options_chart.py viz/example-options.json -o viz/out/example.png ) \
  && ok "options chart renders" || warn "options chart failed"

step "Warm-up: MCP server packages"
run npm cache add @upstash/context7-mcp @playwright/mcp@latest @modelcontextprotocol/server-sequential-thinking >/dev/null 2>&1 \
  && ok "npm MCP packages cached" || warn "could not pre-cache npm MCP packages"
run uv tool install --quiet mcp-server-fetch >/dev/null 2>&1 && ok "mcp-server-fetch cached" || warn "could not cache mcp-server-fetch"
