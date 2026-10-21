# tech-interview-bootstrap

One script to take a **fresh Mac** to "ready for an AI-assisted tech interview",
and one command to remove all of it afterwards.

It sets up Rust (backend), Python (scripting) and TypeScript (frontend),
Claude Code and Codex CLI with shared context, skills and MCP servers, and a
workspace with starters for proofs of concept, ADRs, diagrams and option
comparisons.

## Quick start (nothing installed yet)

`curl` and `tar` ship with macOS, so no git is needed:

```bash
curl -fsSL https://github.com/ken-excel/tech-interview-bootstrap/archive/refs/heads/main.tar.gz | tar xz
cd tech-interview-bootstrap-main
./bootstrap.sh --dry-run   # optional: see every action first
./bootstrap.sh             # asks for your password once (Homebrew)
```

Then open a **new terminal** and:

```bash
ibx doctor            # everything green?
claude                # log in (/login), then exit
codex login
ibx gather            # agent researches tooling + practices → ~/interview/docs/context/
cd ~/interview && claude    # or: codex
```

Takes ~15–25 minutes on a fresh machine (Command Line Tools download dominates).
Re-running is safe: every step is idempotent.

## Remove everything

```bash
ibx uninstall                 # asks before deleting the workspace and Homebrew/CLT
ibx uninstall --yes --all     # no questions; removes everything the kit created
ibx uninstall --keep-workspace
```

## What gets installed, and where

Nearly everything lives in one folder, `~/.interview-env`, so cleanup is
mostly deleting it. Things that can't live there are recorded in
`~/.interview-env/manifest` and removed individually. **Anything you already
had is detected and left alone** — never recorded, never removed.

| Thing | How | Location |
|---|---|---|
| Xcode Command Line Tools, Homebrew | official installers (only if missing) | system (removal asks) |
| jq, ripgrep, fd, gh, d2, graphviz, shellcheck, tree | Homebrew | only newly-installed formulae are recorded |
| Rust stable + clippy, rustfmt, rust-analyzer | rustup | `~/.interview-env/{rustup,cargo}` |
| Python 3.14 + ruff | uv (standalone) | `~/.interview-env/{bin,uv}` |
| Node LTS + Codex CLI + mermaid-cli | fnm (standalone) + npm | `~/.interview-env/fnm` |
| Claude Code | native installer | `~/.local/bin/claude`, `~/.claude*` (recorded) |
| Codex config, auth, skills | `CODEX_HOME` | `~/.interview-env/codex` |
| Caches (uv, npm, puppeteer, playwright) | env vars | `~/.interview-env/cache` |
| Shell hook | 3 lines between markers | `~/.zshrc`, `~/.bash_profile` |
| Workspace | template copy + git init | `~/interview` |

Credentials: Codex is set to store auth in `$CODEX_HOME/auth.json` (deleted
with the sandbox); Claude Code's keychain item is deleted on uninstall if the
kit installed Claude Code.

## The workspace (`~/interview`)

```
AGENTS.md                 shared agent instructions (Codex reads directly)
CLAUDE.md                 imports AGENTS.md for Claude Code
.mcp.json                 MCP servers for Claude Code (project scope)
.claude/settings.json     safe command allow-list, auto-enable project MCP
.agents/skills/           skills, linked into .claude/skills and $CODEX_HOME/skills
poc/rust-api/             axum + tokio API with tests       → cargo run
poc/py-scripts/           uv project: httpx, pydantic, rich → uv run main.py
poc/web/                  Vite + React + TS, vitest, /api proxy → npm run dev
docs/adr/                 ADR template
docs/design/              design-doc template
docs/context/             best-practices.md (sourced scan) + `ibx gather` output
docs/code-review.md       review checklist with severity levels
NOTES.md                  running decisions / next step (survives compaction)
.claude/hooks/format.sh   auto-format .rs/.py after each Claude edit
diagrams/                 Mermaid + D2 examples, render.sh → diagrams/out/*.svg
viz/options_chart.py      weighted option scoring → table + chart
```

All three starters are built and tested during bootstrap, so the first build
during the call is instant.

### Agent context

Built from current guidance by Anthropic, OpenAI and widely used open-source
projects — see
[`docs/context/best-practices.md`](workspace-template/docs/context/best-practices.md)
for the sourced scan, and §8 there for how each practice maps to this kit.

- **Working agreement** in `AGENTS.md` (kept short on purpose — both vendors
  warn that long instruction files get ignored): the candidate drives; the
  agent offers options and waits, works explore → plan → implement, test
  first, and shows evidence (command + output) for every step. "Done" is
  defined explicitly.
- **Skills** (work in both CLIs): `interview-copilot` (default loop),
  `spec` (interview → SPEC.md), `review` (fresh-context review against
  `docs/code-review.md`), `adr`, `diagram` (C4 levels), `compare-options`,
  `poc-scaffold`, plus `webapp-testing`, `mcp-builder`, `frontend-design`,
  `skill-creator` linked from
  [anthropics/skills](https://github.com/anthropics/skills).
- **Guardrails over instructions:** a Claude Code hook formats Rust/Python
  after every edit; permission allow/deny lists in `.claude/settings.json`;
  Codex runs `workspace-write` + `on-request` approvals.
- **NOTES.md** keeps decisions and the next step outside the context window.
- **MCP servers** (both CLIs): `context7` (current library docs),
  `sequential-thinking`, `playwright` (browser checks); Codex also gets
  `fetch`.
- **`ibx gather`** runs Claude Code (`claude -p`) or Codex (`codex exec`)
  headless with [a research prompt](agent-kit/prompts/gather-context.md). It
  writes sourced notes on engineering practices, a system-design cheatsheet,
  current agent tooling, and a ranked `proposed-installs.md`. It is allowed to
  write only into `docs/context/` and installs nothing; you review and decide.
  `ibx gather both` runs both agents for comparison.

### Optional: heavier workflow plugin

[obra/superpowers](https://github.com/obra/superpowers) (brainstorm → plan →
subagent execution → TDD → review) is the most widely adopted open-source
workflow for both CLIs. It's not installed by default because its
full-ceremony loop is heavy for a 60-minute interview. To try it:
`/plugin install superpowers@claude-plugins-official` in Claude Code, or
`/plugins` → search "superpowers" in Codex.

## `ibx` commands

| Command | Does |
|---|---|
| `ibx doctor [--mcp]` | verify tools, workspace, logins (and MCP health) |
| `ibx gather [claude\|codex\|both]` | agent-researched context into `docs/context/` |
| `ibx render` | render all diagrams to SVG |
| `ibx watch diagrams/x.d2` | live-reloading D2 preview — handy while screen sharing |
| `ibx update` | re-run bootstrap |
| `ibx uninstall [flags]` | remove everything |

## Customising

Edit `config.env` or override on the command line:

```bash
WORKSPACE=~/code/interview PYTHON_VERSION=3.13 NODE_VERSION=22 ./bootstrap.sh
BREW_CASKS="visual-studio-code" ./bootstrap.sh     # also install an editor
AGENTS=claude ./bootstrap.sh                        # Claude Code only
./bootstrap.sh --only workspace                     # re-copy templates (never overwrites your edits)
./bootstrap.sh --skip warm
```

## Interview-day checklist

- [ ] `ibx doctor` all green; both CLIs logged in.
- [ ] `cd ~/interview/poc/rust-api && cargo run`, then `cd ../web && npm run dev` — page shows "Rust API: up".
- [ ] Do Not Disturb on; close chat apps; bump terminal font size for screen share.
- [ ] Read `docs/context/README.md`; skim `AGENTS.md` so you know what the agent was told.
- [ ] Practise one loop: restate → options → plan → small step → explain.

## Layout of this repo

```
bootstrap.sh  uninstall.sh  doctor.sh  config.env  Makefile
bin/ibx                     dispatcher put on PATH
lib/common.sh               logging, dry-run, manifest helpers (bash 3.2 safe)
steps/NN-*.sh               preflight, homebrew, rust, python, node, agents, workspace, warm
agent-kit/                  AGENTS.md, CLAUDE.md, MCP + Codex config, skills, gather prompt
workspace-template/         starters, templates, diagrams, viz
```
