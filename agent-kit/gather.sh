#!/bin/bash
# Let an agent CLI research tooling + practices and write docs/context/*.md.
#   ibx gather            use claude if logged in, else codex
#   ibx gather claude     force Claude Code
#   ibx gather codex      force Codex
#   ibx gather both       run both; Codex writes to docs/context/codex/
set -euo pipefail
# shellcheck source=../lib/common.sh
. "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"
load_env

PROMPT_FILE="$KIT_DIR/agent-kit/prompts/gather-context.md"
cd "$WORKSPACE"
mkdir -p docs/context

run_claude() {
  step "Claude Code: researching → docs/context/"
  claude -p "$(cat "$PROMPT_FILE")" \
    --permission-mode acceptEdits \
    --allowedTools "WebSearch" "WebFetch" "Read" "Glob" "Grep" \
      "Write(docs/context/**)" "Edit(docs/context/**)" "mcp__context7"
}

run_codex() {
  local out="${1:-docs/context}"
  step "Codex: researching → $out/"
  local p
  p="$(cat "$PROMPT_FILE")"
  if [ "$out" != "docs/context" ]; then
    p="$p

Write your files under \`$out/\` instead of \`docs/context/\`."
  fi
  # workspace-write sandbox: Codex can only write inside the workspace.
  # Live web search enabled for this run; the fetch MCP server is a fallback.
  codex exec --sandbox workspace-write -c 'web_search="live"' "$p"
}

claude_ready() { have claude && claude -p "reply with OK" --max-turns 1 >/dev/null 2>&1; }
codex_ready()  { have codex && [ -f "$CODEX_HOME/auth.json" ]; }

case "${1:-auto}" in
  claude) run_claude ;;
  codex)  run_codex ;;
  both)   run_claude; mkdir -p docs/context/codex; run_codex docs/context/codex ;;
  auto)
    if claude_ready; then run_claude
    elif codex_ready; then run_codex
    else die "No agent is logged in. Run 'claude' (then /login) or 'codex login' first."
    fi ;;
  *) die "usage: ibx gather [claude|codex|both]" ;;
esac

step "Review"
info "Read docs/context/README.md, then decide on docs/context/proposed-installs.md."
info "Commit what you want to keep:  git -C \"$WORKSPACE\" add docs/context && git commit -m 'docs: gathered context'"
