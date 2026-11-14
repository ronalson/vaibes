#!/usr/bin/env bash
# Run the vaibes workflow skills from this checkout against a throwaway clone of
# dry-vaibes and record evidence for every step. See ../SKILL.md.
#
#   vaibes-verify.sh start   [--no-verify] [run-id]         -> prints RUN_DIR
#   vaibes-verify.sh doctor  <run-dir>
#   vaibes-verify.sh agent   <run-dir> <step> <skill> [instructions...]
#   vaibes-verify.sh state   <run-dir> <step>
#   vaibes-verify.sh cleanup <run-dir>
#
# Layout of a run:
#   <run-dir>/dry-vaibes/            throwaway clone, no remote; removed by cleanup
#   <run-dir>/dry-vaibes.worktrees/  where delegate puts worktrees; removed by cleanup
#   <run-dir>/evidence/              proof; never removed by this script
set -uo pipefail

VAIBES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SKILL_DIR="$VAIBES/.claude/skills/verify-vaibes"
ROOT="${VERIFY_VAIBES_ROOT:-${TMPDIR:-/tmp}/verify-vaibes}"
SOURCE="${DRY_VAIBES_REPO:-git@github.com:ronalson/dry-vaibes.git}"
REF="${DRY_VAIBES_REF:-main}"

die() { echo "vaibes-verify: $*" >&2; exit 2; }

need_run() {
  [[ -n "${1:-}" && -f "$1/run.env" ]] || die "not a run dir (missing run.env): ${1:-<none>}"
  RUN_DIR="$(cd "$1" && pwd)"
  # shellcheck disable=SC1091
  source "$RUN_DIR/run.env"
}

# Next evidence number, so files sort in run order.
next_n() { printf '%02d' $(( $(find "$RUN_DIR/evidence" -maxdepth 1 -name '[0-9][0-9]-*' | sed 's|.*/\([0-9][0-9]\)-.*|\1|' | sort -u | wc -l) + 1 )); }

log() { printf '%s\n' "$@" >>"$RUN_DIR/evidence/transcript.md"; }

cmd_start() {
  local fixture="$SKILL_DIR/fixtures/clear-command.md" no_verify=0
  if [[ "${1:-}" == --no-verify ]]; then
    fixture="$SKILL_DIR/fixtures/clear-command-no-verify.md" no_verify=1
    shift
  fi
  local id="${1:-$(date +%Y%m%d-%H%M%S)-$$}"
  local dir="$ROOT/$id"
  [[ -e "$dir" ]] && die "run dir already exists: $dir"
  mkdir -p "$dir/evidence" || die "cannot create $dir"
  dir="$(cd "$dir" && pwd -P)"
  local app="$dir/dry-vaibes"
  git clone --quiet --branch "$REF" "$SOURCE" "$app" || die "cannot clone $SOURCE at $REF"
  # No remote, so nothing the run does can be pushed.
  git -C "$app" remote remove origin
  if (( no_verify )); then
    # A repo without a verify-<app> skill, committed so the tree starts clean.
    git -C "$app" rm -rq .claude/skills/verify-tasks
    git -C "$app" -c user.name=verify-vaibes -c user.email=verify-vaibes@localhost \
      commit -qm "Remove verify-tasks for a no-verify run" || die "cannot commit the verify-tasks removal"
  fi
  mkdir -p "$app/context/specs"
  # context/ is gitignored in dry-vaibes, as delegate expects.
  cp "$fixture" "$app/context/specs/clear-command.md"
  sed '/^## Phases$/,$d' "$fixture" >"$app/context/specs/clear-command-unphased.md"
  cat >"$dir/run.env" <<EOF
APP='$app'
FIXTURE='$fixture'
BASE='$(git -C "$app" rev-parse HEAD)'
EOF
  {
    echo "# verify-vaibes run $id"
    echo
    echo "- vaibes under test: $VAIBES ($(git -C "$VAIBES" rev-parse --short HEAD)$(git -C "$VAIBES" diff --quiet HEAD 2>/dev/null || echo ', dirty'))"
    echo "- dry-vaibes: $SOURCE at $REF ($(git -C "$app" rev-parse --short HEAD))"
    echo "- fixture: $fixture"
    echo "- claude: $(claude --version 2>/dev/null || echo missing)"
    echo "- started: $(date -u +%FT%TZ)"
  } >"$dir/evidence/transcript.md"
  echo "RUN_DIR=$dir"
}

cmd_doctor() {
  need_run "${1:-}"
  local ok=1 v
  v="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null)" || v=0
  if (( v >= 22 )); then echo "ok   node $(node --version)"; else echo "FAIL node >=22 required (have ${v})"; ok=0; fi
  if command -v claude >/dev/null; then echo "ok   $(claude --version)"; else echo "FAIL claude not on PATH"; ok=0; fi
  local s
  for s in breakdown delegate review handoff; do
    if [[ -f "$VAIBES/skills/$s/SKILL.md" ]]; then echo "ok   skill under test $VAIBES/skills/$s"; else echo "FAIL missing $VAIBES/skills/$s/SKILL.md"; ok=0; fi
  done
  for s in worker scout; do
    if [[ -f "$HOME/.claude/agents/$s.md" ]]; then echo "ok   agent file ~/.claude/agents/$s.md"; else echo "FAIL missing ~/.claude/agents/$s.md (run vaibes install.py)"; ok=0; fi
  done
  if [[ -z "$(git -C "$APP" remote)" ]]; then echo "ok   clone has no remote"; else echo "FAIL clone has a remote: $(git -C "$APP" remote)"; ok=0; fi
  if (cd "$APP" && npm test --silent >/dev/null 2>&1); then echo "ok   npm test passes in the clone"; else echo "FAIL npm test fails in the clone"; ok=0; fi
  # Optional tools: each journey's preconditions say which it needs.
  if [[ "${HERDR_ENV:-}" == 1 ]] && herdr status server >/dev/null 2>&1; then echo "info herdr: inside herdr, server running"; else echo "info herdr: not available here"; fi
  for s in agent-role grok pi; do
    if command -v "$s" >/dev/null; then echo "info $s: $(command -v "$s")"; else echo "info $s: not on PATH"; fi
  done
  # The T3 Code desktop app installs its CLI launcher outside PATH.
  if command -v t3 >/dev/null; then echo "info t3: $(command -v t3)"
  elif [[ -x "$HOME/.t3/bin/t3" ]]; then echo "info t3: $HOME/.t3/bin/t3 (desktop launcher, not on PATH)"
  else echo "info t3: not installed"; fi
  (( ok )) && echo "doctor: healthy" || { echo "doctor: NOT healthy"; exit 1; }
}

# Starts a fresh headless Claude session in the clone that follows one skill
# from this checkout, and records its stream, final result, and denials.
cmd_agent() {
  need_run "${1:-}"
  local step="${2:-}" skill="${3:-}"
  [[ -n "$step" && -n "$skill" ]] || die "usage: agent <run-dir> <step> <skill> [instructions...]"
  [[ -f "$VAIBES/skills/$skill/SKILL.md" ]] || die "no skill under test: $VAIBES/skills/$skill"
  shift 3
  local n base prompt
  n="$(next_n)"; base="$RUN_DIR/evidence/$n-$step"
  prompt="Follow the $skill skill as written in $VAIBES/skills/$skill/SKILL.md. That file is the version under test: read it and every file it links before acting, and do not load any installed skill. You are running unattended, so where the skill says to ask the user, stop and report instead. $*"
  printf '%s\n' "$prompt" >"$base.prompt"
  log "" "## $n $step ($skill)" "" "- prompt: \`$base.prompt\`" "- started: $(date -u +%FT%TZ)"
  (cd "$APP" && claude -p --permission-mode auto --permission-prompts none \
      --strict-mcp-config --disallowedTools Skill \
      --add-dir "$VAIBES/skills" --add-dir "$RUN_DIR" \
      --output-format stream-json --verbose "$prompt" </dev/null) >"$base.jsonl" 2>"$base.err"
  echo $? >"$base.code"
  python3 - "$base" <<'PY'
import json, sys
base = sys.argv[1]
result = None
with open(base + ".jsonl") as f:
    for line in f:
        try:
            event = json.loads(line)
        except ValueError:
            continue
        if event.get("type") == "result":
            result = event
with open(base + ".result.md", "w") as out:
    out.write((result or {}).get("result") or "(no result event)\n")
with open(base + ".denials.json", "w") as out:
    json.dump((result or {}).get("permission_denials", []), out, indent=2)
print(f"[exit {open(base + '.code').read().strip()}] subtype={(result or {}).get('subtype')} "
      f"turns={(result or {}).get('num_turns')} cost_usd={(result or {}).get('total_cost_usd')} "
      f"denials={len((result or {}).get('permission_denials', []))}")
PY
  log "- finished: $(date -u +%FT%TZ), exit $(cat "$base.code")" "- result: \`$base.result.md\`"
  echo "result: $base.result.md"
}

# Records what the run left behind: worktrees, branches, run folder, and any
# herdr workspaces inside this run.
cmd_state() {
  need_run "${1:-}"
  local step="${2:-}"; [[ -n "$step" ]] || die "usage: state <run-dir> <step>"
  local n base; n="$(next_n)"; base="$RUN_DIR/evidence/$n-$step"
  {
    echo "## git worktree list"; git -C "$APP" worktree list
    echo; echo "## branches"; git -C "$APP" branch --list --format='%(refname:short) %(objectname:short)'
    echo; echo "## log since base"; git -C "$APP" log --oneline --all "^$BASE"
    echo; echo "## status"; git -C "$APP" status --short
    echo; echo "## run folders"; find "$APP/context/runs" -type f 2>/dev/null | sed "s|$APP/||" | sort
    echo; echo "## herdr workspaces in this run"; herdr_workspaces
  } >"$base.state.txt" 2>&1
  mkdir -p "$base.context"
  cp -R "$APP/context/." "$base.context/" 2>/dev/null
  log "" "## $n $step (state)" "" "- \`$base.state.txt\`, copy of context/ in \`$base.context/\`"
  cat "$base.state.txt"
}

herdr_workspaces() {
  command -v herdr >/dev/null && [[ "${HERDR_ENV:-}" == 1 ]] || { echo "(herdr not available)"; return; }
  herdr workspace list 2>/dev/null | python3 -c '
import json, sys
root = sys.argv[1]
for w in json.load(sys.stdin)["result"]["workspaces"]:
    path = (w.get("worktree") or {}).get("checkout_path", "")
    if path.startswith(root):
        print(w["workspace_id"], path)
' "$RUN_DIR"
}

cmd_cleanup() {
  need_run "${1:-}"
  cmd_state "$RUN_DIR" cleanup-before >/dev/null
  local ws
  ws="$(herdr_workspaces | grep -v '^(' || true)"
  if [[ -n "$ws" ]]; then
    # Only workspaces whose checkout is inside this run dir, which no one else uses.
    while read -r id path; do
      herdr workspace close "$id" >/dev/null 2>&1 && echo "closed herdr workspace $id ($path)"
    done <<<"$ws"
  fi
  rm -rf "$APP" "$APP.worktrees"
  log "" "## cleanup" "" "- removed the clone and its worktrees: $(date -u +%FT%TZ)"
  echo "cleanup: removed $APP and $APP.worktrees; evidence kept in $RUN_DIR/evidence"
}

case "${1:-}" in
  start) shift; cmd_start "$@" ;;
  doctor) shift; cmd_doctor "$@" ;;
  agent) shift; cmd_agent "$@" ;;
  state) shift; cmd_state "$@" ;;
  cleanup) shift; cmd_cleanup "$@" ;;
  *) sed -n '2,15s/^# \{0,1\}//p' "$0" >&2; exit 2 ;;
esac
