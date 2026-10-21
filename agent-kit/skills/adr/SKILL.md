---
name: adr
description: Write an Architecture Decision Record (ADR) or short design doc. Use when a technical choice is made or debated (database, protocol, framework, sync vs async, build vs buy), or when asked to "record this decision", "write an ADR", "document why", or "write a design doc".
---

# Architecture Decision Records

ADRs live in `docs/adr/NNNN-kebab-title.md`, numbered sequentially. Design
docs live in `docs/design/` and start from `docs/design/template.md`.

## Steps

1. Find the next number: `ls docs/adr | sort | tail -1`.
2. Copy `docs/adr/0000-template.md` to the new file.
3. Fill it in — **one page max**:
   - **Context**: the forces at play, in facts (load, team, deadlines).
   - **Options**: 2–4, each with pros/cons. If options were scored, link the
     chart from `viz/out/` (see `compare-options`).
   - **Decision**: one sentence, active voice ("We will use …").
   - **Consequences**: what gets easier, what gets harder, what we'll revisit
     and when.
4. Status starts as `Proposed`; set `Accepted` only when the candidate agrees.
5. If a diagram clarifies the decision, add it with the `diagram` skill and
   embed the SVG: `![](../../diagrams/out/name.svg)`.

## Style

- Plain words, no marketing. Numbers beat adjectives.
- Write what was *rejected* and why — that's what interviewers probe.
- Superseding: never edit an accepted ADR's decision; write a new one and
  set the old status to `Superseded by NNNN`.
