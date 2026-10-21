#!/bin/bash
# Verify the interview environment. `./doctor.sh --mcp` also asks each agent
# CLI to list (and health-check) its MCP servers.
set -uo pipefail
# shellcheck source=lib/common.sh
. "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"
load_env

FAIL=0
check() { # check <label> <command...>
  local label="$1"; shift
  local out
  if out="$("$@" 2>/dev/null | head -1)" && [ -n "$out" ]; then
    printf '    %s✓%s %-14s %s\n' "$C_G" "$C_0" "$label" "$out"
  else
    printf '    %s✗%s %-14s missing\n' "$C_R" "$C_0" "$label"; FAIL=$((FAIL+1))
  fi
}

step "Toolchains"
check git      git --version
check brew     brew --version
check rustc    rustc --version
check cargo    cargo --version
check clippy   cargo clippy --version
check uv       uv --version
check python   python3 --version
check ruff     ruff --version
check node     node --version
check npm      npm --version

step "Diagrams & utilities"
check d2       d2 --version
check graphviz dot -V
check mermaid  mmdc --version
check jq       jq --version
check rg       rg --version
check gh       gh --version

step "Agents"
check claude   claude --version
check codex    codex --version
[ -f "$CODEX_HOME/auth.json" ] && ok "codex logged in" || warn "codex not logged in → run: codex login"

step "Workspace ($WORKSPACE)"
for f in AGENTS.md CLAUDE.md .mcp.json .claude/settings.json .claude/skills \
         poc/rust-api/Cargo.toml poc/py-scripts/pyproject.toml poc/web/package.json \
         docs/adr/0000-template.md diagrams/render.sh "$CODEX_HOME/config.toml"; do
  case "$f" in /*) p="$f" ;; *) p="$WORKSPACE/$f" ;; esac
  if [ -e "$p" ]; then ok "$f"; else warn "missing $f"; FAIL=$((FAIL+1)); fi
done
SK="$(find -L "$WORKSPACE/.agents/skills" -maxdepth 2 -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
info "skills available: $SK  (Claude: .claude/skills, Codex: \$CODEX_HOME/skills)"

if [ "${1:-}" = "--mcp" ]; then
  step "MCP servers"
  (cd "$WORKSPACE" && have claude && claude mcp list) || warn "claude mcp list failed"
  (cd "$WORKSPACE" && have codex && codex mcp list)   || warn "codex mcp list failed"
fi

step "Result"
if [ "$FAIL" = 0 ]; then ok "all good — ready for the interview"; else warn "$FAIL problem(s); re-run ./bootstrap.sh (it is idempotent)"; fi
exit "$FAIL"
