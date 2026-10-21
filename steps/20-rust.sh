# shellcheck shell=bash
# Rust via rustup, installed into the sandbox (RUSTUP_HOME / CARGO_HOME).

step "Rust ($RUST_TOOLCHAIN)"

if [ -x "$CARGO_HOME/bin/rustup" ]; then
  ok "rustup present in sandbox"
  run "$CARGO_HOME/bin/rustup" update "$RUST_TOOLCHAIN" --no-self-update
else
  run_sh "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    RUSTUP_HOME='$RUSTUP_HOME' CARGO_HOME='$CARGO_HOME' sh -s -- -y --no-modify-path \
    --profile minimal --default-toolchain '$RUST_TOOLCHAIN' \
    -c clippy -c rustfmt -c rust-analyzer"
fi
load_env
[ "$DRY_RUN" = "1" ] || ok "$(rustc --version)"
