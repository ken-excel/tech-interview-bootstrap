@AGENTS.md

## Claude Code specifics

- Skills live in `.claude/skills/` (a link to `.agents/skills/`); invoke them
  by name or let them trigger from their descriptions.
- Use plan mode (Shift+Tab) for anything touching more than one module, and
  show the plan to the candidate before executing.
- MCP servers are declared in `.mcp.json` (project scope).
