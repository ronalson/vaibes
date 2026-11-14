#!/usr/bin/env bash
# Run the vaibes workflow skills from this checkout against a throwaway worktree
# of a local dry-vaibes checkout and record evidence for every step. See ../SKILL.md.
#
#   vaibes-verify.sh start   [--no-verify] [run-id]         -> prints RUN_DIR
#   vaibes-verify.sh doctor  <run-dir>
#   vaibes-verify.sh agent   <run-dir> <step> <skill> [instructions...]
#   vaibes-verify.sh state   <run-dir> <step>
#   vaibes-verify.sh cleanup <run-dir>
#
# Layout of a run:
#   <run-dir>/dry-vaibes/            detached worktree of the dry-vaibes checkout; removed by cleanup
#   <run-dir>/dry-vaibes.worktrees/  where delegate puts worktrees; removed by cleanup
#   <run-dir>/evidence/              proof; never removed by this script
set -uo pipefail

VAIBES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
SKILL_DIR="$VAIBES/.claude/skills/verify-vaibes"
ROOT="${VERIFY_VAIBES_ROOT:-$HOME/.cache/verify-vaibes}"
# The main vaibes checkout, even when this runs from one of its worktrees.
VAIBES_MAIN="$(dirname "$(git -C "$VAIBES" rev-parse --path-format=absolute --git-common-dir)")"
# A local checkout the user has opened Claude in. Worktrees of a trusted repo
# are trusted, so interactive workers do not stop on the folder-trust screen.
SOURCE="${DRY_VAIBES_DIR:-$(dirname "$VAIBES_MAIN")/dry-vaibes}"
REF="${DRY_VAIBES_REF:-main}"
# Every journey uses this topic, so one run at a time per dry-vaibes checkout.
TOPIC=clear

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
  [[ -d "$SOURCE/.git" ]] || die "no dry-vaibes checkout at $SOURCE (set DRY_VAIBES_DIR)"
  local leftover
  leftover="$(git -C "$SOURCE" branch --list "$TOPIC/*")"
  [[ -z "$leftover" ]] || die "$SOURCE already has $TOPIC/* branches; clean up the run that made them first:
$leftover"
  local id="${1:-$(date +%Y%m%d-%H%M%S)-$$}"
  local dir="$ROOT/$id"
  [[ -e "$dir" ]] && die "run dir already exists: $dir"
  mkdir -p "$dir/evidence" || die "cannot create $dir"
  dir="$(cd "$dir" && pwd -P)"
  local app="$dir/dry-vaibes"
  # Detached, so the run adds no branch until delegate creates $TOPIC/run.
  git -C "$SOURCE" worktree add --quiet --detach "$app" "$REF" || die "cannot add a worktree of $SOURCE at $REF"
  if (( no_verify )); then
    # A repo without a verify-<app> skill, committed (detached) so the tree starts clean.
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
SRC='$SOURCE'
FIXTURE='$fixture'
BASE='$(git -C "$app" rev-parse HEAD)'
EOF
  {
    echo "# verify-vaibes run $id"
    echo
    echo "- vaibes under test: $VAIBES ($(git -C "$VAIBES" rev-parse --short HEAD)$(git -C "$VAIBES" diff --quiet HEAD 2>/dev/null || echo ', dirty'))"
    echo "- dry-vaibes: worktree of $SOURCE at $REF ($(git -C "$app" rev-parse --short HEAD))"
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
  if [[ "$(git -C "$APP" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" == "$SRC/.git" ]]; then
    echo "ok   run checkout is a worktree of $SRC"
  else echo "FAIL run checkout is not a worktree of $SRC"; ok=0; fi
  if (cd "$APP" && npm test --silent >/dev/null 2>&1); then echo "ok   npm test passes in the run checkout"; else echo "FAIL npm test fails in the run checkout"; ok=0; fi
  # Interactive workers (delegate under herdr) need $SRC trusted. Only the user
  # grants trust, by opening Claude there once; this only reports it.
  if python3 - "$SRC" 2>/dev/null <<'TRUST'
import json, os, sys
projects = json.load(open(os.path.expanduser("~/.claude.json"))).get("projects", {})
sys.exit(0 if projects.get(sys.argv[1], {}).get("hasTrustDialogAccepted") else 1)
TRUST
  then echo "info claude trust: $SRC is trusted"
  else echo "info claude trust: $SRC is not trusted; interactive workers will stop on the trust screen"; fi
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

# Starts a fresh headless Claude session in the run checkout that follows one
# skill from this checkout, and records its stream, final result, and denials.
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

# Records what the run left behind: its worktrees, its $TOPIC/* branches and
# their commits, the run folder, and any herdr workspaces inside this run.
# The dry-vaibes checkout's other worktrees and branches are left out.
cmd_state() {
  need_run "${1:-}"
  local step="${2:-}"; [[ -n "$step" ]] || die "usage: state <run-dir> <step>"
  local n base; n="$(next_n)"; base="$RUN_DIR/evidence/$n-$step"
  {
    echo "## git worktree list"; git -C "$SRC" worktree list | grep -F "$RUN_DIR/"
    echo; echo "## branches"; git -C "$SRC" branch --list "$TOPIC/*" --format='%(refname:short) %(objectname:short)'
    echo; echo "## log since base"; git -C "$SRC" log --oneline --branches="$TOPIC/*" "^$BASE"
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
  # Worktree workspaces first: herdr does not close the run checkout's own
  # workspace while its worktrees' workspaces are open. Their paths sort after it.
  ws="$(herdr_workspaces | grep -v '^(' | sort -r -k2 || true)"
  if [[ -n "$ws" ]]; then
    # Only workspaces whose checkout is inside this run dir, which no one else uses.
    while read -r id path; do
      if herdr workspace close "$id" >/dev/null 2>&1 </dev/null; then echo "closed herdr workspace $id ($path)"
      else echo "could not close herdr workspace $id ($path); close it by hand"; fi
    done <<<"$ws"
  fi
  rm -rf "$APP" "$APP.worktrees"
  git -C "$SRC" worktree prune
  # start refused to begin while $TOPIC/* branches existed, so these are the run's.
  local b
  for b in $(git -C "$SRC" for-each-ref --format='%(refname:short)' "refs/heads/$TOPIC/"); do
    git -C "$SRC" branch -qD "$b" && echo "deleted branch $b"
  done
  log "" "## cleanup" "" "- removed the run checkout, its worktrees, and its $TOPIC/* branches: $(date -u +%FT%TZ)"
  echo "cleanup: removed $APP, $APP.worktrees, and the $TOPIC/* branches in $SRC; evidence kept in $RUN_DIR/evidence"
}

case "${1:-}" in
  start) shift; cmd_start "$@" ;;
  doctor) shift; cmd_doctor "$@" ;;
  agent) shift; cmd_agent "$@" ;;
  state) shift; cmd_state "$@" ;;
  cleanup) shift; cmd_cleanup "$@" ;;
  *) sed -n '2,15s/^# \{0,1\}//p' "$0" >&2; exit 2 ;;
esac
