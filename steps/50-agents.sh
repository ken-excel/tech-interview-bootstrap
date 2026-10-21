# shellcheck shell=bash
# Agent CLIs: Claude Code (native installer) and OpenAI Codex (npm, sandboxed).

for agent in $AGENTS; do
  case "$agent" in
  claude)
    step "Claude Code"
    if have claude; then
      ok "claude already installed ($(claude --version 2>/dev/null | head -1)); left alone"
    else
      # Native installer writes outside the sandbox; claim each path so
      # uninstall removes exactly what this created.
      claim_path "$HOME/.local/bin/claude"
      claim_path "$HOME/.local/share/claude"
      claim_path "$HOME/.local/state/claude"
      claim_path "$HOME/.cache/claude"
      claim_path "$HOME/.claude"
      claim_path "$HOME/.claude.json"
      record "keychain:Claude Code-credentials"
      run_sh 'curl -fsSL https://claude.ai/install.sh | bash'
      ok "installed claude ($HOME/.local/bin/claude)"
    fi
    ;;
  codex)
    step "OpenAI Codex CLI"
    if [ "$DRY_RUN" = "1" ] || ! have codex; then
      run npm install -g --no-fund --no-audit --loglevel=error @openai/codex
    fi
    run mkdir -p "$CODEX_HOME"
    [ "$DRY_RUN" = "1" ] || ok "codex $(codex --version 2>/dev/null | head -1) (CODEX_HOME=$CODEX_HOME)"
    ;;
  *) warn "unknown agent '$agent' in AGENTS; skipping" ;;
  esac
done
