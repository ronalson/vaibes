# T3 Code runtime

Each worker runs as a T3 Code thread in its own T3-created worktree, through a dedicated "Claude worker" provider instance, and the user watches it in the T3 Code app. Scouts and the reviewer run [headless](headless.md), since T3 Code cannot pass `agent-role`'s read-only flags. The operations are defined in [contract.md](contract.md).

Checked against T3 Code 0.1.9, whose `t3` CLI has only `thread list`, `start`, `send`, and `show`. A worker thread through the provider instance was tested on ronbox (vaibes#27). No full `delegate` run has used this page yet.

`<t3>` below is `t3` when `command -v t3` finds it, otherwise the desktop app's launcher `~/.t3/bin/t3`.

## Setup (once per machine, by the user)

In the T3 Code app, add a Claude provider instance labeled `Claude worker`, with ID `claudeAgent_claude_worker` and launch args `--agent worker --strict-mcp-config`. It runs the `worker` agent file. What it cannot do:

- No per-thread `--add-dir`: T3 Code turns `--add-dir` into an instance-wide setting, so the worker reads and writes only inside its worktree.
- No per-thread effort: effort comes from T3 Code's model selection.
- `--model` on `thread start` replaces the agent file's model.
- T3 Code takes over `--permission-mode`, `--append-system-prompt`, and `--settings`, and adds its own system prompt and MCP server.

If `thread start` reports an unknown provider, the instance is missing: report it and stop.

## Detect

```bash
<t3> thread list --project <repo> --json
```

It succeeds only when the T3 Code server is running and knows the project. When the server is running but the project is not registered, report it and ask whether to run `<t3> project add <repo>` or use the headless runtime. Detection never starts the server.

## Prepare

None.

## Workspace

- **Integration worktree:** plain `git worktree`, as in [../worktrees.md](../worktrees.md#creating-a-worktree), with `-` as the handle.
- **Phase worktree:** created by [Start](#start). T3 Code puts it at `<worktree location>/<project folder name>/<branch with / as ->-<hash>`, where the location is a T3 Code setting, so always read the path back from `<t3> thread show <id> --json` (`worktreePath`). Record it in `worktrees.txt` with `t3:<thread id>` as the handle.
- **Remove:** T3 Code has no command for it, and its own cleanup skips worktrees with untracked files and keeps branches. Copy the result file out as in [Read](#read), delete it from the worktree, then run `git -C <repo> worktree remove <path>`. The cleanup sweep in [../worktrees.md](../worktrees.md#cleanup-sweep) deletes the phase branches as usual.

## Start

The worker cannot read the run folder or the spec, which are outside its worktree. So, as [../worker-packet.md](../worker-packet.md#runtimes-without-the-run-folder) says, the prompt is the packet's full text, and its result path is inside the worktree: `context/runs/<date>-<topic>/phase-<N>-<short-name>-result.md`. Save that prompt as the packet file in the run folder, then start the thread in the background and wait on it later:

```bash
<t3> thread start <repo> - --provider claudeAgent_claude_worker --model <model> \
  --worktree <topic>/run --branch <topic>/<phase> --title worker-<phase> --wait --json \
  < <run folder>/phase-<N>-<short-name>-packet.md > <run folder>/worker-<phase>.t3.json
```

- `--model` is required with `--provider`. Use the model the `worker` agent file names, unless the phase calls for another.
- Pass the full `<topic>/<phase>` branch; T3 Code uses `--branch` as given.
- Find the thread ID with `<t3> thread list --project <repo> --json` by its title, and record the worker in `agents.txt` with runtime `t3code`, the thread ID as the handle, and the `.t3.json` file as the log.

A wave starts every worker this way before waiting on any.

## Send

Never while the thread waits for an answer (`pendingRequestCount > 0`). A busy thread gets the message as its next turn.

```bash
<t3> thread send <id> - --wait --json < <run folder>/phase-<N>-<short-name>-packet-2.md >> <run folder>/worker-<phase>.t3.json
```

## Wait

Wait for the background `thread start` (or `send`) to exit, then branch on its JSON, not on the exit code alone:

- `pendingRequestCount > 0`, or exit 2: waiting for the user. Report it; never answer it.
- `status` other than `completed`: failed. Exit 1 also covers a cancelled or interrupted turn and an unreachable server.
- `status` `completed`: read the result.

## Read

- **worker:** copy `<worktreePath>/context/runs/<date>-<topic>/phase-<N>-<short-name>-result.md` into the run folder, then judge it by its `**Status:**` line. The thread's reply is only the path.
- **Last messages:** `<t3> thread show <id> --json --messages <n>`. `--messages` defaults to 10 and returns only user and assistant messages.
- **Other roles:** as on the [headless](headless.md#read) page.

## Close

The CLI cannot archive threads. T3 Code can recreate a removed worktree when its thread is reopened, so the Finish report lists the run's thread IDs for the user to archive in the T3 Code app.

## Inspect

The thread in the T3 Code app, or `<t3> thread show <id> --json`.
