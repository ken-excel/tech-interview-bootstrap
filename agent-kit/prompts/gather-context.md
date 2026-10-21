# Task: gather agent tooling + engineering context for an interview workspace

You are setting up context for a candidate who will use you (and possibly
another coding agent) during a live technical interview. The stack is
**Rust (backend), Python (scripting), TypeScript (frontend)**, and the work
will be proofs of concept, design, architectural decisions, quick
visualisation of options, architecture diagrams and flowcharts.

Read `AGENTS.md` first. Then research the web and write concise, current,
**sourced** notes into `docs/context/`. Today's date matters: prefer sources
from the last 6 months and say when something may be stale.

## Write these files (each ≤ 150 lines, Markdown, links inline)

1. `docs/context/engineering-practices.md` — a checklist the agent should
   follow while coding in this repo: Rust (error handling, axum patterns,
   clippy lints worth knowing), Python (uv, ruff, typing, pytest), TypeScript
   (strict TS, React 19 patterns, vitest), plus testing, API design, and
   observability basics. Concrete rules, not essays.
2. `docs/context/system-design-cheatsheet.md` — numbers worth knowing
   (latency/throughput orders of magnitude), common building blocks and when
   to pick each (caches, queues, SQL vs NoSQL, consistency models), and a
   5-step method for design questions.
3. `docs/context/agent-tooling.md` — widely used, well-maintained tooling for
   **Claude Code and Codex CLI**: MCP servers, skills/skill catalogues
   (e.g. anthropics/skills, openai/skills), plugins, and workflows. For each:
   what it does, why it helps in an interview setting, install command for
   *both* CLIs where possible, and maintenance signal (stars/last release).
   Only include things you verified exist today.
4. `docs/context/proposed-installs.md` — a short ranked list (max 8) of
   additions you recommend for this workspace, each with the exact command
   and the config snippet for `.mcp.json` (Claude) and
   `$CODEX_HOME/config.toml` (Codex). **Do not install anything** — the
   candidate will review and decide.
5. `docs/context/README.md` — a 10-line index of the files above and when
   to read each.

## Rules

- Do not modify anything outside `docs/context/`.
- Do not install packages, add MCP servers, or change config.
- Cite sources as links. If two sources disagree, say so.
- Prefer official docs (code.claude.com, developers.openai.com/codex,
  modelcontextprotocol.io, docs.rs, docs.astral.sh, react.dev, vite.dev).
- Finish with a 5-line summary of what you wrote.
