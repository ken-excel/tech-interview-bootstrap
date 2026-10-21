---
name: poc-scaffold
description: Start a proof of concept fast using the workspace starters (Rust axum backend, Python uv scripts, TypeScript Vite+React frontend). Use when asked to build, prototype, spike or scaffold something, or to add an endpoint, script or page.
---

# PoC scaffolding

Starters are pre-built (caches warm), so the first build is seconds.

| Layer | Path | Run | Test |
|---|---|---|---|
| Backend (Rust) | `poc/rust-api` | `cargo run` → 127.0.0.1:3000 | `cargo test` |
| Scripts (Python) | `poc/py-scripts` | `uv run main.py` | `uv run pytest -q` |
| Frontend (TS) | `poc/web` | `npm run dev` → :5173 | `npm test` |

The Vite dev server proxies `/api/*` to `127.0.0.1:3000`, so the frontend
can call the Rust API without CORS setup.

## New PoC

Copy the starter rather than editing it, so the original stays as a
reference:

```bash
cp -R poc/rust-api poc/<name>-api && sed -i '' 's/^name = "rust-api"/name = "<name>-api"/' poc/<name>-api/Cargo.toml
cp -R poc/py-scripts poc/<name>-scripts
cp -R poc/web poc/<name>-web   # then: cd poc/<name>-web && npm install
```

## Adding things

- **Rust endpoint**: add a handler fn in `src/main.rs` (or a new module once
  there are >3), register it in `app()`, add a test using
  `tower::ServiceExt::oneshot` like the existing `health` test.
  Add deps with `cargo add <crate>`.
- **Python**: `uv add <pkg>`; keep logic in functions with type hints;
  test in `tests/`. One-off script? `uv init --script x.py && uv add --script x.py <pkg>`.
- **Frontend**: pure logic in `src/lib/` with a `*.test.ts` next to it;
  components in `src/`. Call the API via `fetch('/api/...')` wrapped in a
  typed function.

## Definition of done for a PoC step

Builds, tests pass, one command to run it, and a 2-line note in the commit
message saying what it proves.
