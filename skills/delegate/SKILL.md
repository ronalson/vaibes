---
name: delegate
description: Execute a broken-down spec with worker agents. Start each worker in its own worktree, dispatch phases wave by wave, collect result files and evidence, merge in an integration worktree, and clean up. Use when the user asks to delegate or run a spec's phases.
---

# Delegate

You orchestrate and do not implement. Every role runs as its own agent the user can inspect: workers in their own worktrees, scouts beside them. You write packets, start agents, read results, merge, and clean up. Code changes go only to `worker`.

This skill only executes. The plan comes from a spec written with `handoff` or `type-spec` and split with `breakdown`. When the review is next, point to the `review` skill; do not run a reviewer here.

How agents are started, waited on, and read depends on the runtime. The steps below name the operations from [references/runtimes/contract.md](references/runtimes/contract.md), and the chosen runtime's page gives their commands.

## Input

A spec in `<repo>/context/specs/` with a `## Validation` section and a `## Phases` section written by `breakdown`: one `### Phase N — <short-name>` per phase, with Wave, Depends on, Agent, Owns, Lands, Acceptance, and Gate.

Stop and point to the right skill when:

- the spec has no `## Phases` section: run `breakdown`;
- Validation fails "Complete or incomplete" in [../handoff/references/validation.md](../handoff/references/validation.md): fix it with `handoff` or `type-spec`;
- two phases in the same wave share an `Owns` path: send it back to `breakdown`.

## Preflight

Stop and report if any required check fails.

1. Choose the runtime as in [Choosing a runtime](references/runtimes/contract.md#choosing-a-runtime), and read its page, including any setup it requires. If that setup is missing, report it and stop.
2. The `worker` and `scout` agent files exist. `agent-role` plus `grok` or `pi` are needed only for a Grok or Pi scout, and Pi is not installed on every machine; report the ones missing and stop only if the run needs them. Commands are in [references/roles.md](references/roles.md#preflight).
3. Create the run folder `<repo>/context/runs/<date>-<topic>/` with an empty `worktrees.txt` and `agents.txt`.
4. Run the runtime's Prepare operation, when its page has one.
5. Run the [stale-worktree check](references/worktrees.md#stale-worktree-check) and ask the user what to do with worktrees older than 7 days before going on.
6. If `git -C <repo> branch --list '<topic>/*'` shows branches, an earlier run left them. Ask whether to resume from them, pick a new topic, or delete them.

The repo does not need a `verify-<app>` skill. When a phase's Gate lists Feature map IDs, the worker runs those journeys; when it lists none, the phase is gated on its Commands.

## Run the waves

Read [references/roles.md](references/roles.md) before starting the first agent, and [references/worktrees.md](references/worktrees.md) before creating the first worktree.

1. **Integration worktree.** Create `<worktree folder>/<topic>-run` on branch `<topic>/run` from the current HEAD with the Workspace operation. You merge here, never by switching branches in the main checkout, which other sessions use.
2. **Per phase in the wave.** Create its worktree on `<topic>/<phase-short-name>` from `<topic>/run` with the Workspace operation, record it in `worktrees.txt`, and write its packet from [references/worker-packet.md](references/worker-packet.md). Start `worker` in its workspace with the Start operation, and prompt: "Read the packet at `<path>` and do what it says. If you think this is a good idea, do it. Otherwise, suggest something else."
3. **Wait** for every worker in the wave with the Wait operation, one after another. An agent waiting for the user is a stop: read the agent with the Read operation, then report.
4. **Read each result file** before acting on it. Start with its `**Status:**` line (`done`, `blocked`, or `failed`), then check the claims that matter against the branch: the commit exists, `git diff --name-only <topic>/run...<topic>/<phase>` stays inside Owns, and the gate's evidence is there. Say plainly when a result is wrong or thin. A worker that exited cleanly with no result file, or with `blocked` or `failed`, did not finish.
5. **Gate.** A phase passes when every Gate item that is not `None` has evidence: command output and exit codes for Commands, the fail-first check failing before and passing after when the gate lists one, each Review risk's named checks failing with only what the risk describes broken and passing once restored, and `verify-<app>` artifacts when the gate lists Feature map IDs. No evidence means not done. A named check that passes with the code broken is a gate failure, even when another test fails. On a failure, give the same worker a new packet that quotes what failed, with the Send operation. A second failure is a stop.
6. **Merge** each passing phase branch into `<topic>/run` in the integration worktree. Resolve conflicts yourself when you understand both sides; stop and report when you are not sure. After the wave merges, run the gate Commands that cover more than one phase there, as in [worktrees.md](references/worktrees.md#merging).
7. **Remove** each merged phase's worktree and mark it removed in `worktrees.txt`, as in [worktrees.md](references/worktrees.md#removing-a-worktree).
8. Start the next wave from the updated `<topic>/run` without checking in.

Use the fewest agents that finish. Send a scout only for a sweeper question that stands between you and the next step, such as where a conflicting caller lives. The scout's job is in [roles.md](references/roles.md#scout). Packets are self-contained: quote the evidence, never "continue the work".

## Resuming

An interrupted run is re-dispatched, never continued. That includes a runtime that restarts and keeps its layout but not its agents. Read each phase's result file and branch. Keep the phases that passed their gate, and start a fresh worker with a new packet for each of the rest, quoting what its branch already holds.

## Stops

Report to the user and wait when:

- a packet's Stop if hits;
- a phase fails its gate twice after re-dispatch;
- an agent waits on a trust or approval prompt (never answer it);
- a worker reports a blocked or destructive action;
- a merge conflict you cannot resolve with confidence.

Otherwise read each wave's results and dispatch the next wave without checking in. Continuing never overrides confirmation for risky or destructive actions: those still need the user's yes.

## Finish

1. Close the agents in `agents.txt` with the Close operation, then run the cleanup sweep in [worktrees.md](references/worktrees.md#cleanup-sweep). It removes every listed worktree and the phase branches; `<topic>/run` stays as the result.
2. Tell the user what changed per phase, the files, the checks and their results, the evidence paths in the run folder, anything the runtime page says to report, such as T3 Code thread IDs to archive, and what is unresolved. Results in the run folder are not shown to the user.
3. Point to the spec path and to `review` for `<base>..<topic>/run`.
