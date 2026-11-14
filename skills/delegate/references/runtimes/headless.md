# headless runtime

Every role runs as a one-shot print-mode process in the background, with its output in a log file in the run folder. Worktrees are plain `git worktree`s. It needs only the agent CLIs, so it runs anywhere, including the roles another runtime cannot run. The operations are defined in [contract.md](contract.md).

Untested end to end: no `delegate` or `review` run has used this page yet.

## Detect

Always available. It is last in the detection order.

## Prepare

None.

## Workspace

The plain `git worktree` commands in [../worktrees.md](../worktrees.md#creating-a-worktree), with `-` as the handle in `worktrees.txt`. Remove with `git -C <repo> worktree remove <path>`.

## Start

Generate a session ID with `python3 -c 'import uuid; print(uuid.uuid4())'`, then start the role in the background with its output in the run folder:

- **worker**, from its worktree: the [worker command](../roles.md#worker-command) plus `-p --permission-prompts none --session-id <uuid> --output-format stream-json --verbose "<prompt>" < /dev/null > <run folder>/worker-<name>.log 2>&1`.
- **Claude scout**: `agent-role scout -p "<prompt>" > <run folder>/scout-<name>.log 2>&1`.
- **Grok or Pi scout, and the reviewer**: `agent-role <role> [--via <kind>] ... -p "<prompt>" > <run folder>/<role>-<name>.log 2>&1`, from the directory the role reads. Grok's session ID is in the log's `agent-role: grok session <id>` line.

`--permission-prompts none` denies anything that would prompt instead of waiting, so no agent waits for the user. Record each agent in `agents.txt` with runtime `headless`, `<pid>:<session id>` as the handle, and the log path.

Print mode shows no folder-trust screen, but it still runs the repo's `.claude/settings.json` hooks.

## Send

Once the worker's process has exited, resume its session with the new prompt:

```bash
claude -p --resume <session-id> --permission-prompts none --output-format stream-json --verbose "<prompt>" < /dev/null >> <log> 2>&1
```

## Wait

Wait for the process to exit. A finished process returns at once.

## Read

- **worker:** the result file, judged by its `**Status:**` line. Also read the last `result` event in the log: a non-empty `permission_denials` means the worker was blocked, whatever the exit code and even when the result file says `done`. Report it as a stop.
- **Claude scout:** the `result` field of the last `result` event in the log.
- **Grok and Pi:** as in [../roles.md](../roles.md#reading-answers).

## Close

Nothing stays open once a process exits. If one still runs at the end of the run, report its PID; do not kill it unless the user says so.

## Inspect

`tail -f <run folder>/<role>-<name>.log`.

## Limits

In print mode, background work stops after 10 minutes of idle waiting unless `CLAUDE_CODE_PRINT_BG_WAIT_CEILING_MS` is set. A `verify-<app>` journey that runs a dev server can hit this. A finished session can also linger that long before it exits; the final `result` event in its log is already the answer.
