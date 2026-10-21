@AGENTS.md

## Claude Code specifics

- Skills: `.claude/skills/` (links to `.agents/skills/`).
- Use plan mode (Shift+Tab) for multi-file changes; show the plan first.
- Use a subagent for wide exploration and for the `review` step, so the main
  context stays clean.
- A PostToolUse hook formats `.rs` and `.py` files after every edit
  (`.claude/hooks/format.sh`); don't run formatters manually for those.
- When compacting, preserve: the list of modified files, the test commands,
  decisions made, and the current step of the plan.
