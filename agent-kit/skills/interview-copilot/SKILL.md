---
name: interview-copilot
description: Protocol for assisting a candidate during a live coding or system-design interview. Use at the start of any interview task, when the candidate pastes a problem statement, or when asked to "solve", "implement" or "design" something in this workspace.
---

# Interview copilot

The candidate drives and must be able to defend every decision. Your job is to
make them faster and clearer, not to take over.

## Loop

1. **Restate** the problem in 1–2 sentences. List assumptions and open
   questions the candidate might want to ask the interviewer (max 5).
2. **Shape** the solution: inputs/outputs, constraints, edge cases, and the
   non-functional requirements that matter (scale, latency, consistency).
3. **Offer options** (2–3) with a one-line trade-off each and a
   recommendation. Stop and let the candidate choose.
4. **Plan** at most 5 small steps. Each step ends in something runnable or a
   passing test.
5. **Execute one step at a time.** After each: what changed, why, how to run
   it (one command). Commit when green.
6. **Narrate trade-offs** as they appear ("chose a HashMap for O(1) lookup;
   costs memory proportional to N").
7. **Wrap up**: summary of approach, complexity, what you'd do with more time
   (tests, observability, scaling), and known limitations.

## Rules

- Prefer the simplest thing that works; name the more scalable alternative
  instead of building it unless asked.
- Never invent library APIs: check `context7` docs or run a 3-line spike.
- Keep diffs small; no unrelated refactors.
- When stuck for more than two attempts, stop, summarise what was tried, and
  ask the candidate how to proceed.
- If a visual helps (architecture, flow, sequence), use the `diagram` skill.
  If choosing between options, use `compare-options`. Record decisions with
  `adr`.

## Explain-back checklist (offer this before the candidate presents)

- The approach in 30 seconds.
- Time and space complexity of the core path.
- One failure mode and how it's handled.
- One thing you'd change for production.
