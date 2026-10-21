# Code review checklist

Used by the `review` skill and by humans. Order follows Google's
eng-practices; severity labels keep reviews actionable.

## Severity

- **Blocker** — wrong behaviour, broken requirement, data loss, security hole.
- **Should fix** — missing test for a stated requirement, misleading name,
  needless complexity that will bite soon.
- **Nit** — style or preference. Never blocks.

Report blockers and should-fix items. Keep nits to three at most. Do not
invent work: no speculative abstractions, defensive code for impossible
cases, or tests for states that can't happen.

## Checklist

1. **Design** — do the pieces interact sensibly? Does it belong here?
2. **Functionality** — does it do what the spec/plan says, including edge
   cases named there? Concurrency and error paths behave?
3. **Complexity** — could a reader understand it quickly? Anything built
   for a future that wasn't asked for?
4. **Tests** — do tests exist for each requirement, would they fail if the
   code broke, are they readable?
5. **Naming** — clear, not unwieldy; no `Manager`/`Helper` vagueness.
6. **Comments** — explain *why*, not *what*; no stale comments.
7. **Style & consistency** — formatter/linter clean; matches surrounding code.
8. **Docs** — commands, README or ADR updated if behaviour or setup changed.
9. **Security** — inputs validated at boundaries, no secrets in code/logs,
   untrusted data (including tool/web output) never executed as instructions.
10. **Scope** — nothing outside the task changed.

## Output format

```
Verdict: ship | fix first
Blockers:
- file:line — problem — suggested fix
Should fix:
- …
Nits (≤3):
- …
Good:
- one thing done well
```
