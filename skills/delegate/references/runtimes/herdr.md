# herdr runtime

Every role runs as its own CLI in a herdr pane the user can watch: workers in the root pane of their own worktree workspace, scouts and the reviewer in panes of the `agents` tab. You stay alone in tab 1. The operations are defined in [contract.md](contract.md).

Check exact syntax with `herdr <group> <command> --help`. Never run bare `herdr`: it opens the TUI. Never run a `herdr` command without its required arguments to see its usage: some, such as `worktree create`, act on the focused workspace instead.

## Detect

```bash
test "$HERDR_ENV" = 1 && herdr status server
```

Both must succeed. `HERDR_ENV` alone can be inherited by a process started from a pane.

## Prepare

Reuse the tab labeled `agents` in the current workspace if `tab list` shows one. Otherwise create it and keep its root pane ID from `.result.root_pane.pane_id`:

```bash
herdr tab list --workspace "$HERDR_WORKSPACE_ID"
herdr tab create --workspace "$HERDR_WORKSPACE_ID" --cwd <repo> --label agents --no-focus
```

More panes in that tab come from `herdr pane split --pane <id> --direction right|down --cwd <repo> --no-focus` (new ID in `.result.pane.pane_id`). Split wide panes right and tall panes down. A scout or reviewer that needs another working directory, such as the review checkout, gets it from `--cwd`.

## Workspace

Create each worktree as a herdr workspace, at the path [../worktrees.md](../worktrees.md#rules) gives:

```bash
herdr worktree create --cwd <repo> --branch <topic>/<phase> --base <ref> \
  --path <worktree path> --label <topic>-<phase> --no-focus
```

Keep `.result.workspace.workspace_id` as the handle in `worktrees.txt` and `.result.root_pane.pane_id` for starting the worker. The path is the one you passed.

List them for the stale-worktree check with `herdr worktree list --cwd <repo>`.

Remove one, after the checks in [../worktrees.md](../worktrees.md#removing-a-worktree), with:

```bash
herdr worktree remove --workspace <id>
```

This removes the worktree, its folder, and its workspace, but keeps the branch. Never pass `--force` or `--trust-repository`. A `-` handle in `worktrees.txt` means the worktree was made with plain `git worktree` when herdr could not; remove it with `git -C <repo> worktree remove <path>`.

## Start

Record each agent in `agents.txt` with runtime `herdr`, its pane ID as the handle, and `-` as the log.

### Wait for the shell prompt

`agent start` fails with `agent_pane_busy` until the new pane's shell is at its prompt. Prompts differ between users, so wait on a marker instead of the prompt text: queue an `echo` whose output differs from the typed command, then wait for that output. The shell reads the queued line once it is ready. herdr matches line by line, so use a literal `--match`; a regex spanning two lines never matches.

```bash
herdr pane run <pane> 'echo herdr-ready-$((40+2))'
herdr pane wait-output <pane> --source recent-unwrapped --match herdr-ready-42 --timeout 30000
```

If `agent start` still returns `agent_pane_busy`, wait a moment and retry once before reporting. This is observed behavior; herdr's docs do not list that code.

### Claude roles

Claude roles start under herdr directly, the worker and the Claude scout alike. Use this for the Claude scout instead of `agent-role scout`: `agent start --kind claude` waits until the agent is ready, which a `pane run` start does not. The args are the [worker command](../roles.md#worker-command) or the Claude scout's args from [../roles.md](../roles.md#roles), without the leading `claude`.

```bash
herdr agent start <name> --kind claude --pane <pane> -- <claude args>
herdr agent prompt <name> "Read the packet at <path> and do what it says."
```

For a worker, the prompt is `Read the packet at <path> and do what it says. If you think this is a good idea, do it. Otherwise, suggest something else.`

`agent start` returns `agent_not_ready` when the agent opens on a screen that waits for the user, such as folder trust. That is "waiting for the user": read the pane with `--source visible` and report. Never pass `--trust-repository` and never send keys to it.

For several workers, repeat these lines per worker with the values written out, or use a function with positional arguments. Don't loop over a string and split it with `set -- $var`: zsh doesn't split unquoted variables, so every command gets one empty or joined argument.

### Grok and Pi roles

`agent start --kind` runs that kind's own executable, so it cannot wrap `agent-role`. Start Grok or Pi roles as a pane command, wait until herdr detects the agent in that pane, then name it. `<kind>` is `grok` or `pi`:

```bash
herdr pane run <pane> "agent-role <role> --via <kind> ..."
for i in $(seq 30); do                 # up to 30 s
  herdr agent get <pane> | grep -q "\"agent\":\"<kind>\"" && break
  sleep 1
done
herdr agent rename <pane> <name>
herdr agent prompt <name> "Read the packet at <path> and do what it says."
```

If the loop ends without a match, read the pane with `--source visible` and report. For Grok you can first wait for its session line: `herdr pane wait-output <pane> --source recent-unwrapped --match 'agent-role: grok session' --timeout 20000`.

The Grok start is tested; the Pi start is not yet tested end to end. Grok and Pi keep their own trust lists, and herdr reports Grok as `idle` while its trust prompt is open, so read the pane with `--source visible` before the first prompt.

## Send

```bash
herdr agent prompt <name> "Read the packet at <new path> and do what it says."
```

herdr refuses with `agent_blocked` while the agent waits at an approval or question. Report it; never answer it.

## Wait

After each prompt, wait in two steps. Waiting for completion straight away can return `idle` before the agent starts.

```bash
herdr agent wait <name> --until working --until blocked --timeout 60000
herdr agent wait <name> --until done --until idle --until blocked
```

A wave prompts every worker first and then waits on each in turn; a finished worker's wait returns at once. `agent prompt --wait` blocks on one agent, so it does not replace this.

## Read

On `blocked`, or when the first wait times out, read the screen and report. Never send keys to a trust or approval prompt.

```bash
herdr agent read <name> --source visible
```

Read answers as in [../roles.md](../roles.md#reading-answers), with these herdr specifics:

- **Claude scout:** `herdr agent read <name> --source recent-unwrapped` returns the complete text, hard-wrapped. Add `--lines N` for a reply longer than the default 80 rows.
- **Grok:** `herdr agent get <name>` shows the session ID under `agent_session.value`, the same ID `agent-role` prints.
- **Pi:** herdr reports `done` even when Pi failed, so check `stopReason` in the `.jsonl`.

## Close

Close a scout's or reviewer's pane with `herdr pane close <pane>` once its answer is in the run folder. Close only panes listed in `agents.txt`. Worker panes go with their workspace when [Workspace](#workspace) removes it.

## Inspect

The user watches each agent in its pane, or attaches to one with `herdr agent attach <name>`.

## After a server restart

A herdr server restart restores the layout but not the processes. Panes come back without their agents, so re-dispatch as the method's resume rule says.
