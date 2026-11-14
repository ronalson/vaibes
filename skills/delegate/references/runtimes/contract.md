# Runtime contract

A runtime is how the run's agents are started, reached again, and read. `delegate` and `review` use only the operations on this page and take the exact commands from the chosen runtime's page. The method, the roles, and their commands stay the same whichever runtime runs them; see [../roles.md](../roles.md).

## Choosing a runtime

Use the runtime the user names in the request. Otherwise use the first that applies:

1. [herdr](herdr.md), when `HERDR_ENV=1` and `herdr status server` succeeds. `HERDR_ENV` alone is not enough: a process started from a herdr pane inherits it.
2. [t3code](t3code.md), when its Detect succeeds: the T3 Code server is running and knows the repo.
3. [headless](headless.md) otherwise.

Detection never starts a server. A runtime page that cannot run a role names the runtime that runs it instead; for example, T3 Code runs the reviewer headless.

## Operations

Each runtime page describes every operation below with exact commands. A runtime that cannot do an operation for a role says which runtime does it instead.

1. **Detect.** Tell whether the runtime is available, with no side effects.
2. **Prepare** (optional). Set up what agents run in, such as a tab for scouts.
3. **Workspace.** Create a worktree for a branch from a base, report its actual path for `worktrees.txt`, list existing ones for the stale-worktree check, and remove one. The git rules around this are in [../worktrees.md](../worktrees.md).
4. **Start.** Start a role in a workspace with the packet prompt, and record it in `agents.txt`. Start can end with the agent waiting for the user, for example on a folder-trust screen. Report that; never answer it.
5. **Send.** Give the same agent a re-dispatch packet. Never send while the agent waits for the user.
6. **Wait.** Wait until the agent finishes, fails, or waits for the user.
7. **Read.** Read the agent's final reply, and detect when it is waiting for an approval or an answer.
8. **Close.** Close what the run opened, using `agents.txt` and `worktrees.txt`. Close nothing the run did not open.

## agents.txt

`<run folder>/agents.txt` lists every agent the run starts, one line each, fields separated by spaces, `-` for an empty field:

```text
<role> <name> <runtime> <handle> <log>
```

The handle is whatever the runtime needs to reach the agent again, such as a herdr pane ID. The log is a file in the run folder that shows the agent's progress, or `-` when the runtime shows progress elsewhere. Close uses this file; it never closes an agent that is not listed.

## What every runtime guarantees

- The user can inspect each agent's progress, live or in a log file in the run folder. Each runtime page names the command.
- Nothing answers an approval prompt on the agent's behalf. "Waiting for the user" is reported, never answered.
- Success is judged from the result file's `**Status:**` line for workers and from the reply for read-only roles, never from an exit code or an `idle` or `done` state.

## Adding a runtime

Add one page in this folder that covers every operation above, including Detect and how the user inspects an agent, and add its line to [Choosing a runtime](#choosing-a-runtime) in the order it should win. Nothing outside this folder lists the runtimes, so `rules/delegation.md`, the README, and the skills' descriptions do not change. A runtime without a page is not in the detection order.
