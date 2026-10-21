# shellcheck shell=bash
# Workspace: agent context, skills, MCP config for Claude + Codex, starters.

step "Kit copy + ibx command"
# Keep a copy of the kit inside the sandbox so `ibx uninstall` works even
# after you delete the downloaded folder.
if [ "$DRY_RUN" != "1" ] && [ "$KIT_DIR" != "$IBX_HOME/kit" ]; then
  rm -rf "$IBX_HOME/kit"
  mkdir -p "$IBX_HOME/kit"
  (cd "$KIT_DIR" && tar --exclude .git -cf - .) | (cd "$IBX_HOME/kit" && tar -xf -)
  ln -sf "$IBX_HOME/kit/bin/ibx" "$IBX_HOME/bin/ibx"
fi
ok "ibx → $IBX_HOME/bin/ibx"

step "Workspace at $WORKSPACE"
if [ ! -e "$WORKSPACE" ]; then
  record "workspace:$WORKSPACE"
fi
run mkdir -p "$WORKSPACE"

# copy_missing <src_dir> <dst_dir>: never overwrite files you already edited.
copy_missing() {
  [ "$DRY_RUN" = "1" ] && { info "[dry-run] copy $1 → $2"; return 0; }
  mkdir -p "$2"
  (cd "$1" && find . -type f) | while IFS= read -r f; do
    if [ ! -e "$2/$f" ]; then
      mkdir -p "$2/$(dirname "$f")"
      cp -p "$1/$f" "$2/$f"
    fi
  done
}

copy_missing "$KIT_DIR/workspace-template" "$WORKSPACE"
copy_missing "$KIT_DIR/agent-kit/context" "$WORKSPACE"          # AGENTS.md, CLAUDE.md, .mcp.json, .claude/settings.json
copy_missing "$KIT_DIR/agent-kit/skills" "$WORKSPACE/.agents/skills"
ok "templates copied (existing files untouched)"

if [ "$DRY_RUN" != "1" ]; then
  # One source of truth in .agents/skills: Codex reads it from the repo
  # (and from $CODEX_HOME/skills, linked below); Claude reads .claude/skills.
  mkdir -p "$WORKSPACE/.claude"
  [ -e "$WORKSPACE/.claude/skills" ] || ln -s ../.agents/skills "$WORKSPACE/.claude/skills"
  chmod +x "$WORKSPACE"/diagrams/*.sh "$WORKSPACE"/viz/*.py "$WORKSPACE"/.claude/hooks/*.sh 2>/dev/null || true
fi

step "Vendor skills"
# VENDOR_SKILLS: specs separated by ';', each "<url>|<subdir>|<names...>"
printf '%s\n' "$VENDOR_SKILLS" | tr ';' '\n' | while IFS='|' read -r url subdir names; do
  [ -n "$url" ] || continue
  repo_name="$(basename "$url" .git)"
  dest="$IBX_HOME/vendor/$repo_name"
  if [ -d "$dest/.git" ]; then run git -C "$dest" pull --quiet --ff-only || true
  else run git clone --quiet --depth 1 "$url" "$dest" || { warn "could not clone $url"; continue; }
  fi
  for n in $names; do
    if [ "$DRY_RUN" = "1" ]; then
      info "[dry-run] link $repo_name/$subdir/$n → .agents/skills/$n"
    elif [ -d "$dest/$subdir/$n" ]; then
      [ -e "$WORKSPACE/.agents/skills/$n" ] || run ln -s "$dest/$subdir/$n" "$WORKSPACE/.agents/skills/$n"
      ok "linked $repo_name/$n"
    else
      warn "$repo_name has no skill '$n' (upstream may have renamed it)"
    fi
  done
done

step "Codex config ($CODEX_HOME)"
if [ "$DRY_RUN" != "1" ]; then
  mkdir -p "$CODEX_HOME/skills"
  if [ ! -f "$CODEX_HOME/config.toml" ]; then
    sed "s#@WORKSPACE@#$WORKSPACE#g" "$KIT_DIR/agent-kit/codex-config.toml" > "$CODEX_HOME/config.toml"
  fi
  for s in "$WORKSPACE"/.agents/skills/*/; do
    n="$(basename "$s")"
    [ -e "$CODEX_HOME/skills/$n" ] || ln -s "${s%/}" "$CODEX_HOME/skills/$n"
  done
fi
ok "MCP servers + skills wired for Codex"

step "Git repo"
if [ "$DRY_RUN" != "1" ] && [ ! -d "$WORKSPACE/.git" ]; then
  git -C "$WORKSPACE" init --quiet -b main
  git -C "$WORKSPACE" add -A
  git -C "$WORKSPACE" -c user.name="interview-bootstrap" -c user.email="bootstrap@localhost" \
    commit --quiet -m "chore: bootstrap interview workspace"
  ok "initialised $WORKSPACE as a git repo"
else
  ok "git repo present"
fi
