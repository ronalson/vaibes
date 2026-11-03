# Launching and reading agents

Read this before starting the first agent of a run. Check exact syntax with `herdr <group> <command> --help`. Never run bare `herdr`: it opens the TUI.

## Preflight

```bash
test "$HERDR_ENV" = 1
ls ~/.claude/agents/worker.md ~/.claude/agents/scout.md
command -v grok pi agent-role          # needed only for Grok or Pi scouts
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
| `worker` | Root pane of its `herdr worktree create` workspace | `claude --agent worker --model <m> --effort <e> --permission-mode auto --strict-mcp-config --add-dir <run folder> --add-dir <repo>/context/specs` | `opus` + `medium`; `sonnet` + `low` for simple phases |
| `scout` (Claude) | Pane in the `agents` tab | `claude --agent scout --effort medium --strict-mcp-config` | Haiku 5.5 from the agent file |
| `scout` (Pi) | Pane in the `agents` tab | `agent-role scout --via pi --session-dir <run folder>/scout-<name>` | `openrouter/z-ai/glm-5.3-flash` |

Why the flags: `effort` in an agent file does not apply under `--agent`, so pass `--effort`. Without `--strict-mcp-config` a worker sees MCP tools outside its tool list. Workers need `--add-dir <run folder>` to write the result file and `--add-dir <repo>/context/specs` to read the spec by absolute path.

Agent names must match `[a-z][a-z0-9_-]{0,31}` and be unique among live agents. Use `worker-<phase-short-name>` and `scout-<topic>`, shortened to fit.

## Wait for the shell prompt

`agent start` fails with `agent_pane_busy` until the new pane's shell is at its prompt. Prompts differ between users, so wait on a marker instead of the prompt text: queue an `echo` whose output differs from the typed command, then wait for the marker followed by another line, which is the prompt drawn after it. The shell reads the queued line once it is ready.

```bash
herdr pane run <pane> 'echo herdr-ready-$((40+2))'
herdr pane wait-output <pane> --source recent-unwrapped --regex 'herdr-ready-42\n.*\S' --timeout 30000
```

If `agent start` still returns `agent_pane_busy`, wait a moment and retry once before reporting.

## Start and prompt

Claude roles start under herdr directly:

```bash
herdr agent start <name> --kind claude --pane <pane> -- <claude args from the table>
herdr agent prompt <name> "Read the packet at <path> and do what it says."
```

`agent start --kind` runs that kind's own executable, so it cannot wrap `agent-role`. Start Pi or Grok roles as a pane command, then name the agent herdr detects in that pane:

```bash
herdr pane run <pane> "agent-role scout --via pi --session-dir <run folder>/scout-<name>"
herdr agent rename <pane> <name>
herdr agent prompt <name> "Read the packet at <path> and do what it says."
```

This `pane run` form is not yet tested end to end: confirm with `herdr agent get <pane>` that herdr detected the agent before prompting. Grok and Pi keep their own trust lists, and herdr reports Grok as `idle` while its trust prompt is open, so read the pane with `--source visible` before the first prompt.

## Wait and read back

After each prompt, wait in two steps. Waiting for completion straight away can return `idle` before the agent starts.

```bash
herdr agent wait <name> --until working --timeout 60000
herdr agent wait <name> --until done --until idle --until blocked
```

With several workers in a wave, wait on each in turn; a finished worker's wait returns at once.

On `blocked`, read the screen and report. Never send keys to a trust or approval prompt.

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

- **Grok:** `grok export <session-id> <file>`; the output file must not exist yet. The session ID is in `herdr agent get <name>` under `agent_session.value`, and `agent-role` also prints `agent-role: grok session <id>` to stderr. Pane text is unreliable for Grok and Pi.

Close a scout's pane with `herdr pane close <pane>` once its answer is in the run folder. Close only panes this run created.
