# Roles

Read this before starting the first agent of a run. It says what each role does, the command that starts it, and how to read its answer. Where each agent runs, and the exact commands to start, wait on, and read it, are on the chosen runtime's page; see [runtimes/contract.md](runtimes/contract.md).

This page names no default model or tool. Those, and each role's read-only flags, live only in the agent files (`claude-agents/*.md`, installed to `~/.claude/agents/`) and in `bin/agent-role` (installed to `~/.local/bin/agent-role`). When this page and those files disagree, those files win.

## Preflight

Check each binary on its own line: with several names, `command -v` exits 1 in zsh if any is missing and 0 in bash if any is found.

```bash
ls ~/.claude/agents/worker.md ~/.claude/agents/scout.md
command -v agent-role                  # only for a Grok or Pi role, or the reviewer
command -v grok                        # only for a Grok role
command -v pi                          # only for a Pi role
```

## Roles

| Role | Does | Command |
|---|---|---|
| `worker` | Implements one phase in its own worktree. Claude only. | The [worker command](#worker-command) |
| `scout` (Claude, default) | Read-only sweeper questions. | `agent-role scout`, which runs `claude --agent scout --effort medium --strict-mcp-config`. A runtime that starts Claude itself uses those args. |
| `scout` (Pi, only where `pi` is installed) | The same, from another model family. | `agent-role scout --via pi --session-dir <run folder>/scout-<name>` |
| `scout` (Grok, untested as scout) | The same, from another model family. | `agent-role scout --via grok` |
| `reviewer` | Read-only review for the `review` skill. | `agent-role reviewer`, or `agent-role reviewer --via pi --session-dir <run folder>/reviewer` when the user asks for Pi |

Name agents `worker-<phase-short-name>`, `scout-<topic>`, and `reviewer`, shortened to fit `[a-z][a-z0-9_-]{0,31}`, and unique among the run's live agents. The name goes in `agents.txt`.

## Worker command

```bash
claude --agent worker --model <m> --effort <e> --permission-mode auto --strict-mcp-config \
  --add-dir <run folder> --add-dir <repo>/context/specs
```

Why each flag:

- `--model` and `--effort` are per-session choices. Leave out `--model` to use the agent file's model; pass it only when the phase calls for another. `effort` in an agent file does not apply under `--agent`, so always pass `--effort`, following "Prefer `high`" in [Advisor](#advisor).
- `--permission-mode auto` lets the worker edit and run checks in its worktree without a prompt for each step.
- Without `--strict-mcp-config` a worker sees MCP tools outside its tool list.
- `--add-dir <run folder>` lets it write the result file, and `--add-dir <repo>/context/specs` lets it read the spec by absolute path.

Runtime pages link here instead of repeating this command.

## Scout

The Claude scout stays on its agent file's model at medium effort. Use it as a high-volume sweeper: classification, routing, extraction, searching files, reading logs, summarizing, pattern-matching, or walking files to flag a smell. It never writes code. A side task that needs judgment goes to a worker.

## Reading answers

- **worker:** the result file the packet names. Its reply is only that path. Judge the phase from the file's `**Status:**` line, never from how the agent exited.
- **Claude scout:** its final reply. The runtime page says where to read it.
- **Pi:** the last assistant message in the session `.jsonl` under `--session-dir`. A runtime can report Pi as finished when it failed, so treat `stopReason: "error"` as a failure:

  ```bash
  jq -s '[.[] | select(.type=="message" and .message.role=="assistant")] | last
    | {stop: .message.stopReason, text: ([.message.content[] | select(.type=="text") | .text] | join(""))}' \
    <run folder>/scout-<name>/*.jsonl
  ```

- **Grok:** `grok export <session-id> <file>`; the output file must not exist yet. `agent-role` prints `agent-role: grok session <id>` to stderr (it sets the ID with `--session-id`). Screen text is unreliable for Grok and Pi.

## Advisor

For a long or hard worker phase only (a big refactor, a migration, an architecture decision, or a bug that keeps coming back), pass an advisor on that session. `--advisor opus` is the cheaper first choice. `--advisor fable` is for when the cost is worth it. Fable is never the daily or main model. Add the flag to that worker's `claude` args.

Call Fable when Opus is too same-y, too cautious, or stuck in a circle, when the work is unprovable or creative, or when a pile of work sits unmerged because the worker keeps finding more to do (a ship or audit call). Do not start a long, careful harness-building phase, or an ordinary worker phase, on Fable.

`--advisor fable` is an in-session check. For a ship call on a long existing thread, switch that session to Fable briefly to audit, rather than only passing the advisor flag.

Never pass an advisor on a scout. Never save `advisorModel` as a default. Subagents inherit the advisor, so a saved default makes every Haiku scout call it too.

Skip `low` and `max` effort, especially Fable at `max`. Prefer `high`. Use `xhigh` to audit or turn every stone, not as the default.

Each advisor call re-reads the whole conversation with no prompt cache, so use it per session for hard work, not routinely. See the [advisor docs](https://code.claude.com/docs/en/advisor).
