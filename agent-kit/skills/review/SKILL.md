---
name: review
description: Review the current diff or a named change in a fresh context against the plan/spec and docs/code-review.md, reporting blockers and should-fix gaps only. Use when asked to "review", "check my changes", "is this ready", "look for bugs", or before declaring a task done.
---

# Review

A reviewer that didn't write the code catches more. Prefer running this in a
**subagent / fresh session** that sees only the diff and the criteria.

## Steps

1. Collect the change: `git diff` (uncommitted) or `git diff main...HEAD`.
   If the user names files or a commit, use those.
2. Collect the criteria: `SPEC.md` or the agreed plan if one exists, plus
   `docs/code-review.md`.
3. Run the project's checks and include their output as evidence:
   - Rust: `cargo test && cargo clippy -- -D warnings`
   - Python: `uv run pytest -q && uv run ruff check .`
   - TypeScript: `npm test && npm run typecheck`
4. Walk the checklist in `docs/code-review.md`. Check every requirement in
   the spec has code **and** a test.
5. Report in the checklist's output format.

## Rules

- Flag only gaps that affect correctness or the stated requirements as
  blockers/should-fix. Everything else is a nit (max 3) or omitted.
- Don't propose rewrites, new abstractions, or speculative hardening.
- Quote file:line for every finding and suggest the smallest fix.
- If checks fail, that is the first blocker — show the failing output.
