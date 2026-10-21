# AGENTS.md — interview workspace

Shared instructions for every coding agent in this repo (Codex reads this file
directly; Claude Code reads it via `CLAUDE.md`).

## 1. Working agreement (read first)

This is a **live technical interview**. The human candidate drives; you assist.

- The candidate chooses the approach. Before writing non-trivial code, restate
  the problem in one or two sentences and propose a plan of at most 5 steps.
  Wait for a go-ahead when the plan involves an architectural choice.
- When there is a real decision, offer 2–3 options with trade-offs and a
  recommendation, then let the candidate pick. Record picked decisions in
  `docs/adr/` (use the `adr` skill).
- Work in **small, reviewable steps**: one concern per change, explain what
  changed and why in 2–3 lines. No sweeping rewrites, no surprise refactors.
- The candidate must be able to explain every line. Prefer boring, readable
  code over clever code. Name things plainly.
- Say "I don't know" or "let me check" rather than guessing. Use the
  `context7` MCP server for current library docs before writing API calls.
- Never paste secrets into code or chat. Never run destructive commands
  (`rm -rf`, `git reset --hard`, force-push) without explicit approval.
- Screen may be shared: keep terminal output short; summarise long logs.

## 2. Repo map

| Path | What |
|---|---|
| `poc/rust-api/` | Rust backend starter (axum + tokio), `cargo run` → :3000 |
| `poc/py-scripts/` | Python scripting starter (uv, httpx, pydantic, pytest) |
| `poc/web/` | TypeScript frontend starter (Vite + React, vitest) |
| `docs/adr/` | Architecture Decision Records (`0000-template.md`) |
| `docs/design/` | Short design docs (`template.md`) |
| `docs/context/` | Researched best practices & tooling notes (`ibx gather`) |
| `diagrams/` | Diagrams as code: Mermaid `.mmd`, D2 `.d2` → `diagrams/out/*.svg` |
| `viz/` | Quick charts (weighted option comparison) via `uv run` |
| `.agents/skills/` | Skills shared by Claude (`.claude/skills`) and Codex |

## 3. Commands

```bash
# Rust
cd poc/rust-api && cargo run            # dev server on 127.0.0.1:3000
cargo test && cargo clippy -- -D warnings && cargo fmt
# Python
cd poc/py-scripts && uv run main.py     # uv add <pkg> to add deps
uv run pytest -q && uv run ruff check . && uv run ruff format .
# TypeScript
cd poc/web && npm run dev               # http://localhost:5173 (proxies /api → :3000)
npm test && npm run typecheck && npm run build
# Diagrams & charts
./diagrams/render.sh                    # all .mmd/.d2 → diagrams/out/*.svg
d2 --watch diagrams/architecture.d2     # live preview in the browser
uv run viz/options_chart.py viz/example-options.json -o viz/out/options.png
```

## 4. Engineering defaults

**General**
- Make it work → make it right → make it fast. For a PoC, stop at "right".
- Tests for the core logic first (happy path + one edge case); skip mocks
  unless I/O makes them necessary.
- Validate input at boundaries; fail loudly with useful messages.
- Keep functions small and pure where possible; isolate I/O at the edges.
- Commit after each green step with a conventional message (`feat:`, `fix:`).

**Rust** — edition 2024; `anyhow` in binaries, `thiserror` for library errors;
no `unwrap()` outside tests and `main` setup; `cargo clippy -- -D warnings`
clean; shared state via `Arc<…>` in axum `State`; prefer `&str`/slices in APIs.

**Python** — 3.13+, type hints everywhere, `pydantic` models for external
data, `httpx` for HTTP, `ruff` for lint+format, `pytest` with plain asserts.
One-off scripts may use PEP 723 inline deps (`uv run script.py`).

**TypeScript** — `strict` on, no `any` (use `unknown` + narrowing); pure
logic in `src/lib/` with vitest tests; components small; fetch through a
typed client function; no global state library unless asked.

**Architecture & design**
- State assumptions and non-functional requirements (latency, scale,
  consistency, cost) before choosing components.
- Draw the system first (`diagram` skill): context → containers → key flow.
- For each significant choice, write an ADR: context, options, decision,
  consequences. Keep each under one page.
- Compare options explicitly (`compare-options` skill) — weighted criteria,
  scored, visualised — rather than arguing from preference.

## 5. Skills available

`interview-copilot`, `adr`, `diagram`, `compare-options`, `poc-scaffold`,
plus vendor skills linked from public repos (e.g. `webapp-testing`,
`mcp-builder`, `frontend-design`, `skill-creator`). Check `.agents/skills/`.

## 6. MCP servers

- `context7` — up-to-date library documentation. Use before writing code
  against any third-party API.
- `sequential-thinking` — structured step-by-step reasoning for design work.
- `playwright` — drive a real browser to check the frontend works.
- `fetch` (Codex) — fetch a URL as markdown.

## 7. Researched context

If `docs/context/` has files, read `docs/context/README.md` first; it indexes
notes gathered at setup time (practices, tooling, proposed installs).
