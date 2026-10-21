---
name: spec
description: Interview the user about a feature or problem, then write a self-contained SPEC.md (requirements, interfaces, out of scope, edge cases, end-to-end verification). Use when the task is non-trivial or ambiguous, or when asked to "spec this", "clarify requirements", "interview me", or "write a spec".
---

# Spec

Turn a fuzzy brief into a spec precise enough that a fresh session could
implement it without asking anything.

## Interview (keep it short in a live interview: 3–6 questions)

Ask about the hard parts, not the obvious ones:
- Inputs, outputs, and the scale that matters (N, QPS, data size).
- Edge cases and failure behaviour (empty, duplicate, concurrent, partial
  failure, timeouts).
- Non-functional constraints: latency, consistency, cost, security.
- What is explicitly **out of scope**.
- How we will know it works end to end.

Use the CLI's question tool if available (Claude: AskUserQuestion);
otherwise ask in one numbered list and wait.

## Write `SPEC.md`

```markdown
# <Feature>
## Goal            — one paragraph, user-visible outcome
## Requirements    — numbered, testable (R1, R2, …)
## Interfaces      — endpoints / function signatures / data shapes
## Files           — files to create or change
## Edge cases      — each mapped to a requirement
## Out of scope    — explicit list
## Assumptions     — anything we decided without asking
## Verification    — exact commands + expected result proving R1..Rn
```

Then stop and show the spec. Implementation starts only after the user
agrees; for big specs, start a fresh session (`/clear`) and implement from
`SPEC.md` test-first (red → green).
