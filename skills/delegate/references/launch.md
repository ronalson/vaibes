# Launching and reading agents

Read this before starting the first agent of a run. Check exact syntax with `herdr <group> <command> --help`. Never run bare `herdr`: it opens the TUI.

Check each binary on its own line: with several names, `command -v` exits 1 in zsh if any is missing and 0 in bash if any is found.

## Preflight

```bash
test "$HERDR_ENV" = 1
ls ~/.claude/agents/worker.md ~/.claude/agents/scout.md
command -v agent-role                  # only for a Grok or Pi role
command -v grok                        # only for a Grok role
command -v pi                          # only for a Pi role
ls <repo>/.claude/skills/verify-*/SKILL.md
herdr tab list --workspace "$HERDR_WORKSPACE_ID"
```

Reuse the tab labeled `agents` if `tab list` shows one. Otherwise create it and keep its root pane ID from `.result.root_pane.pane_id`:

```bash
herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd <repo> --label agents --no-focus
```

More panes in that tab come from `herdr pane split --pane <id> --direction right|down --cwd <repo> --no-focus` (new ID in `.result.pane.pane_id`). Split wide panes right and tall panes down.

## Roles

| Role | Where | Command | Defaults |
|---|---|---|---|
| `worker` | Root pane of its `herdr worktree create` workspace | `claude --agent worker --model <m> --effort <e> --permission-mode auto --strict-mcp-config --add-dir <run folder> --add-dir <repo>/context/specs` | `opus` + `high` |
| `scout` (Claude, default) | Pane in the `agents` tab | `claude --agent scout --effort medium --strict-mcp-config`, the same command `agent-role scout` runs | Haiku 5.5 from the agent file |
| `scout` (Pi, only where `pi` is installed) | Pane in the `agents` tab | `agent-role scout --via pi --session-dir <run folder>/scout-<name>` | `openrouter/z-ai/glm-5.3-flash` |
| `scout` (Grok, untested as scout) | Pane in the `agents` tab | `agent-role scout --via grok` | `grok-4.7`, effort `medium` |

Why the flags: `effort` in an agent file does not apply under `--agent`, so pass `--effort`. Without `--strict-mcp-config` a worker sees MCP tools outside its tool list. Workers need `--add-dir <run folder>` to write the result file and `--add-dir <repo>/context/specs` to read the spec by absolute path.

The Claude scout stays on Haiku at medium effort. Use it as a high-volume sweeper: classification, routing, extraction, searching files, reading logs, summarizing, pattern-matching, or walking files to flag a smell. It never writes code. A side task that needs judgment goes to an Opus worker.

Agent names must match `[a-z][a-z0-9_-]{0,31}` and be unique among live agents. Use `worker-<phase-short-name>` and `scout-<topic>`, shortened to fit.

## Advisor

For a long or hard worker phase only (a big refactor, a migration, an architecture decision, or a bug that keeps coming back), pass an advisor on that session. `--advisor opus` is the cheaper first choice. `--advisor fable` is for when the cost is worth it. Fable is never the daily or main model. Add the flag to that worker's `claude` args.

Call Fable when Opus is too same-y, too cautious, or stuck in a circle, when the work is unprovable or creative, or when a pile of work sits unmerged because the worker keeps finding more to do (a ship or audit call). Do not start a long, careful harness-building phase, or an ordinary worker phase, on Fable.

`--advisor fable` is an in-session check. For a ship call on a long existing thread, switch that session to Fable briefly to audit, rather than only passing the advisor flag.

Never pass an advisor on a scout. Never save `advisorModel` as a default. Subagents inherit the advisor, so a saved default makes every Haiku scout call it too.

Skip `low` and `max` effort, especially Fable at `max`. Prefer `high`. Use `xhigh` to audit or turn every stone, not as the default.

Each advisor call re-reads the whole conversation with no prompt cache, so use it per session for hard work, not routinely. See the [advisor docs](https://code.claude.com/docs/en/advisor).

## Wait for the shell prompt

`agent start` fails with `agent_pane_busy` until the new pane's shell is at its prompt. Prompts differ between users, so wait on a marker instead of the prompt text: queue an `echo` whose output differs from the typed command, then wait for that output. The shell reads the queued line once it is ready. herdr matches line by line, so use a literal `--match`; a regex spanning two lines never matches.

```bash
herdr pane run <pane> 'echo herdr-ready-$((40+2))'
herdr pane wait-output <pane> --source recent-unwrapped --match herdr-ready-42 --timeout 30000
```

If `agent start` still returns `agent_pane_busy`, wait a moment and retry once before reporting.

## Start and prompt

Claude roles start under herdr directly. Use this for the Claude scout instead of `agent-role scout`: `agent start --kind claude` waits until the agent is ready, which a `pane run` start does not.

```bash
herdr agent start <name> --kind claude --pane <pane> -- <claude args from the table>
herdr agent prompt <name> "Read the packet at <path> and do what it says."
```

For a worker, the prompt is `Read the packet at <path> and do what it says. If you think this is a good idea, do it. Otherwise, suggest something else.`

For several workers, repeat these lines per worker with the values written out, or use a function with positional arguments. Don't loop over a string and split it with `set -- $var`: zsh doesn't split unquoted variables, so every command gets one empty or joined argument.

`agent start --kind` runs that kind's own executable, so it cannot wrap `agent-role`. Start Pi or Grok roles as a pane command, wait until herdr detects the agent in that pane, then name it. `<kind>` is `grok` or `pi`:

```bash
herdr pane run <pane> "agent-role scout --via <kind> ..."
for i in $(seq 30); do                 # up to 30 s
  herdr agent get <pane> | grep -q "\"agent\":\"<kind>\"" && break
  sleep 1
done
herdr agent rename <pane> <name>
herdr agent prompt <name> "Read the packet at <path> and do what it says."
```

If the loop ends without a match, read the pane with `--source visible` and report. For Grok you can first wait for its session line: `herdr pane wait-output <pane> --source recent-unwrapped --match 'agent-role: grok session' --timeout 20000`.

The Grok start is tested; the Pi start is not yet tested end to end. Grok and Pi keep their own trust lists, and herdr reports Grok as `idle` while its trust prompt is open, so read the pane with `--source visible` before the first prompt.

## Wait and read back

After each prompt, wait in two steps. Waiting for completion straight away can return `idle` before the agent starts.

```bash
herdr agent wait <name> --until working --until blocked --timeout 60000
herdr agent wait <name> --until done --until idle --until blocked
```

With several workers in a wave, wait on each in turn; a finished worker's wait returns at once.

On `blocked`, or when the first wait times out, read the screen and report. Never send keys to a trust or approval prompt.

```bash
herdr agent read <name> --source visible
```

Read results per program:

- **worker:** the result file the packet names. The pane reply is only its path.
- **Claude scout:** `herdr agent read <name> --source recent-unwrapped` returns the complete text, hard-wrapped.
- **Pi:** the last assistant message in the session `.jsonl` under `--session-dir`. herdr reports `done` even when Pi failed, so treat `stopReason: "error"` as a failure:

  ```bash
  jq -s '[.[] | select(.type=="message" and .message.role=="assistant")] | last
    | {stop: .message.stopReason, text: ([.message.content[] | select(.type=="text") | .text] | join(""))}' \
    <run folder>/scout-<name>/*.jsonl
  ```

- **Grok:** `grok export <session-id> <file>`; the output file must not exist yet. `agent-role` prints `agent-role: grok session <id>` to stderr (it sets the ID with `--session-id`); `herdr agent get <name>` shows the same ID under `agent_session.value`. Pane text is unreliable for Grok and Pi.

Close a scout's pane with `herdr pane close <pane>` once its answer is in the run folder. Close only panes this run created.
