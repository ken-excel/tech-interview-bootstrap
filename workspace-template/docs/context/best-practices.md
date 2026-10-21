# Best practices for agent-assisted engineering

A curated scan (October 2026) of guidance from Anthropic, OpenAI, the
AGENTS.md standard, and widely used open-source projects. Agents: read the
section you need, not the whole file. Humans: §1 and §8 are the 5-minute read.

Each point is tagged with where it comes from: **[A]** Anthropic,
**[O]** OpenAI, **[OSS]** open-source / industry. Points tagged with both
vendors are the consensus — weight those highest.

---

## 1. The ten rules both vendors agree on

1. **Context is the scarce resource.** Model quality degrades as the context
   window fills; every file read and command output costs attention. Keep
   always-loaded files lean and pull detail in on demand. [A][O]
2. **Give the agent a check it can run.** Tests, a build, a linter, a
   screenshot diff. Without a pass/fail signal, "looks done" is the only stop
   condition and *you* become the verification loop. Ask for evidence
   (command + output), not assertions of success. [A][O]
3. **Explore → plan → implement → commit.** Separate research and planning
   from coding (plan mode: `Shift+Tab` in both CLIs). Skip the plan when you
   could describe the diff in one sentence. [A][O]
4. **A good prompt has four parts:** goal, context (files, errors,
   examples), constraints (conventions, architecture, safety), and what done
   looks like. Point at existing patterns instead of describing them. [A][O]
5. **Let the agent interview you for anything non-trivial**, then write a
   self-contained spec (files, interfaces, out-of-scope, end-to-end
   verification step) and implement from a fresh session. [A][O]
6. **Durable rules go in AGENTS.md / CLAUDE.md or a skill, not in prompts.**
   Add a rule only after you see a repeated mistake; ask the agent for a
   retrospective and update the file. [A][O]
7. **One thread per task.** Clear context between unrelated tasks. After two
   failed corrections on the same issue, stop, reset, and re-prompt with what
   you learned — a clean session beats a polluted one. [A][O]
8. **Use subagents for bounded side work** (exploration, test triage,
   review) so the main thread keeps a clean context; they return short
   summaries. [A][O]
9. **Review in a fresh context.** A reviewer that sees only the diff and the
   criteria isn't biased by the reasoning that produced it. Tell it to report
   only gaps affecting correctness or stated requirements, or it will invent
   work. [A] Codex has `/review` against a branch, commit or uncommitted
   changes, and suggests a `code_review.md` referenced from AGENTS.md. [O]
10. **Start with tight permissions; loosen deliberately.** Sandbox and
    allow-list what you trust; never grant full access before you understand
    the workflow. Use worktrees when running agents in parallel. [A][O]

## 2. AGENTS.md / CLAUDE.md

AGENTS.md is the cross-tool standard: released by OpenAI in August 2025,
now stewarded by the Linux Foundation's Agentic AI Foundation alongside MCP,
and read by Codex, Cursor, Copilot, Gemini CLI, Jules, VS Code and others.
Claude Code reads `CLAUDE.md`, which can import AGENTS.md with `@AGENTS.md`
(this workspace does exactly that). [O][A][OSS]

| Include | Leave out |
|---|---|
| Build/test/lint commands the agent can't guess | Anything inferable from reading the code |
| Style rules that *differ* from language defaults | Standard conventions the model already knows |
| Repo layout and where things live | File-by-file descriptions |
| Project-specific architectural decisions | Long tutorials; full API docs (link instead) |
| Environment quirks, required env vars, gotchas | Frequently changing information |
| PR/branch etiquette; what "done" means | "Write clean code"-style platitudes |

- **Test every line:** "would removing this cause a mistake?" If not, cut it.
  A bloated file makes the agent ignore the rules that matter. [A]
- **Emphasis is a budget.** Mark one critical rule `IMPORTANT`, not ten. [A]
- **Layer by scope.** Global personal file → repo file → subdirectory files;
  the closest file to the working directory wins. Keep the root file short
  and link task-specific docs (planning, code review, architecture). [O]
- Codex embeds at most `project_doc_max_bytes` (32 KiB default) of AGENTS.md
  into the first turn. [O]
- Tell Claude what to keep when compacting, e.g. "preserve the list of
  modified files and test commands". [A]
- Keep progress in a notes file outside the context (`NOTES.md`, a todo
  list) so it survives compaction and resets. [A]

## 3. Skills

A skill is a folder with `SKILL.md` (YAML frontmatter: `name`,
`description`) plus optional reference files and scripts. Both CLIs load only
the name/description up front and read the body when the skill applies
(progressive disclosure). [A][O]

- **One job per skill.** Start from 2–3 concrete use cases and a task that
  already works well by hand, then convert it. [O]
- **The description is the trigger.** Say what it does, when to use it, and
  the phrases a user would actually type. [A][O]
- **Split when it grows.** Move rarely needed material into linked files;
  say whether a bundled script is to be *run* or *read*. [A]
- **Iterate from real use.** Watch where the agent struggles; have it record
  what worked and what went wrong into the skill. [A]
- **Mark side-effecting workflows manual-only** in Claude Code with
  `disable-model-invocation: true`. [A]
- **Locations:** Claude Code `.claude/skills/`; Codex `.agents/skills/`
  (repo) and `~/.agents/skills` (personal). This workspace keeps one copy in
  `.agents/skills/` and links `.claude/skills` to it. [A][O]
- **Security:** a skill can run code and steer the agent. Install only from
  trusted sources; read every bundled file (scripts, dependencies, network
  calls) before enabling a third-party skill. [A]

## 4. Deterministic guardrails beat instructions

- Instructions are advisory; **hooks are guaranteed.** Anything that must
  happen every time (format on save, block writes to a folder, run tests
  before stopping) belongs in a hook. This workspace formats `.rs` and `.py`
  files after every Claude edit via `.claude/hooks/format.sh`. [A]
- Codex equivalents live in `config.toml`: `sandbox_mode`
  (`read-only` → `workspace-write` → `danger-full-access`) and
  `approval_policy`. Keep defaults until a workflow is proven. [O]
- In Claude Code use permission allow-lists (`.claude/settings.json`) and
  `/sandbox` for OS-level isolation instead of clicking through approvals. [A]

## 5. MCP servers and tools

**When to use MCP:** the context lives outside the repo, changes often, or
needs to be a repeatable integration. Start with one or two servers that
remove a manual loop. For services that have a CLI (`gh`, cloud CLIs),
the CLI is usually the most context-efficient option. [O][A]

**Security (OWASP MCP cheat sheet)** [OSS]
- Treat every tool *output* as untrusted data — it can carry injected
  instructions. Require human approval for sensitive follow-up actions.
- Watch for **tool poisoning** (instructions hidden in descriptions/schemas)
  and **rug pulls** (definitions changing after approval); re-review when a
  server updates.
- Least privilege: read-only or narrow scopes, per-server credentials,
  short-lived tokens, no full host access.
- Supply chain: install from verified sources, check package names for
  typosquats, pin versions for anything sensitive.

**If you build tools / MCP servers for an agent** [A]
- Few, purpose-built tools beat one-per-endpoint wrappers; consolidate
  multi-step operations; prefer `search_x` over `list_x`.
- Namespace by service/resource; unambiguous parameter names (`user_id`).
- Return high-signal, human-readable fields; offer a concise/detailed
  response mode; paginate and truncate with sensible defaults.
- Errors should say how to fix the call, with a correct example.
- Design arguments so mistakes are hard (e.g. require absolute paths).
- Iterate with an eval set of realistic multi-step tasks; read transcripts.

## 6. Workflow patterns from the open-source ecosystem

- **Start simple** (Anthropic, *Building effective agents*): the simplest
  thing that works; add agentic complexity only when it measurably helps.
  Known patterns, in rising complexity: prompt chaining, routing,
  parallelization, orchestrator–workers, evaluator–optimizer. These are
  also good vocabulary for system-design answers involving LLMs. [A]
- **Red/green TDD for agents** (Simon Willison, *Agentic Engineering
  Patterns*): write the failing test first, confirm it fails, then implement.
  It makes agent output shorter and more reliable with little extra
  prompting. [OSS]
- **Spec-driven development** (GitHub Spec Kit): constitution
  (non-negotiable principles) → specify (what/why, no tech) → plan
  (how/stack) → tasks → implement. Specs are versioned, reviewable
  artifacts. [OSS]
- **Superpowers** (obra/superpowers, ~300k GitHub stars; plugin for both
  Claude Code and Codex): brainstorm → worktree → written plan → subagent or
  batched execution → TDD → code review between tasks → finish branch. Very
  thorough; heavy for a 60-minute interview, excellent for real projects. [OSS]

## 7. Engineering practices by area

**Code review** (Google eng-practices) — check in this order: design,
functionality, complexity (no over-engineering), tests, naming, comments
(*why* not *what*), style (prefix personal preferences with "Nit:"),
consistency, documentation, every line, broader context, and call out good
things. See `docs/code-review.md`. [OSS]

**Rust** (Microsoft Pragmatic Rust Guidelines) [OSS]
- Applications may use `anyhow`; libraries expose situation-specific error
  types (`thiserror`), with `From` impls so `?` works.
- A panic means "stop": panic on programming bugs, return errors otherwise.
- Structured logging (`tracing` fields, not `format!`); no `println!` in
  services; redact secrets/PII.
- Prefer `async fn`; futures should be `Send`.
- Strong types over strings (`PathBuf`, newtypes with fallible
  constructors); avoid `Service`/`Manager`/`Factory` names.
- `#[expect(lint, reason = "…")]` instead of `#[allow]`; clippy + rustfmt +
  `cargo audit` as gates.

**Python** (Astral toolchain) [OSS]
- `uv` for projects, scripts (PEP 723 inline deps) and Python versions;
  `ruff` for lint + format.
- Type-check with pyright/mypy; Astral's `ty` is very fast but entered beta
  in Dec 2025 and still ships 0.0.x releases — fine for local feedback;
  check its status before making it a CI gate.

**TypeScript** [OSS]
- `strict` (plus `noUncheckedIndexedAccess`) in tsconfig.
- typescript-eslint: start at `recommendedTypeChecked`; move to
  `strictTypeChecked` if the team is fluent in TS (strict rules can change
  outside semver majors).

**Architecture communication** [OSS]
- **C4 model:** draw context → containers → components (→ code) as separate
  diagrams, one level each; simple boxes, notation-agnostic.
- **ADRs** (Nygard / MADR at adr.github.io): one decision per record —
  context, options considered, decision, consequences; supersede rather than
  edit. Template: `docs/adr/0000-template.md`.

## 8. How this maps to the interview

| Guidance | In this workspace |
|---|---|
| Verification loop | Starters ship with tests; AGENTS.md defines "done" as tests + lint + evidence |
| Explore → plan → implement | `interview-copilot` skill; plan mode in both CLIs |
| Interview → spec | `spec` skill writes `SPEC.md` with out-of-scope and verification |
| Fresh-context review | `review` skill + `docs/code-review.md` |
| Lean always-loaded context | AGENTS.md is short; detail lives here and in skills |
| Hooks over instructions | `.claude/hooks/format.sh` formats Rust/Python after each edit |
| Decisions and diagrams | `adr`, `diagram`, `compare-options` skills |
| You drive | Agent proposes options and waits; you choose and explain |

The interview brief expects *you* to own the approach and explain it. These
practices help: small verified steps you can narrate, written decisions you
can point to, and diagrams you can share.

---

## Sources

**Anthropic**
- [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices)
- [Hooks reference](https://code.claude.com/docs/en/hooks) · [How to configure hooks](https://www.claude.com/blog/how-to-configure-hooks)
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
- [Building effective agents](https://www.anthropic.com/research/building-effective-agents)
- [Writing effective tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents)

**OpenAI**
- [Codex best practices](https://developers.openai.com/codex/learn/best-practices)
- [Codex sample configuration](https://developers.openai.com/codex/config-sample)
- [Agentic AI Foundation (AGENTS.md, MCP)](https://openai.com/index/agentic-ai-foundation/)

**Open source / industry**
- [obra/superpowers](https://github.com/obra/superpowers)
- [Spec-driven development with Spec Kit](https://developer.microsoft.com/blog/spec-driven-development-spec-kit/)
- [Simon Willison — Agentic Engineering Patterns](https://simonwillison.net/2026/feb/23/agentic-engineering-patterns)
- [OWASP MCP Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/MCP_Security_Cheat_Sheet.html)
- [Google eng-practices: what to look for in a code review](https://google.github.io/eng-practices/review/reviewer/looking-for.html)
- [Microsoft Pragmatic Rust Guidelines](https://microsoft.github.io/rust-guidelines/)
- [typescript-eslint shared configs](https://typescript-eslint.io/users/configs)
- [ty beta announcement coverage](https://pydevtools.com/blog/ty-beta/)
- [C4 model](https://en.wikipedia.org/wiki/C4_model) · [ADR resources (MADR)](https://adr.github.io/)
