---
name: delegate
description: Execute a broken-down spec in herdr. Start each worker in its own worktree workspace, dispatch phases wave by wave, collect result files and evidence, merge in an integration worktree, and clean up. Use when the user asks to delegate or run a spec's phases. Requires HERDR_ENV=1.
---

# Delegate

You orchestrate and do not implement. Every role runs as its own CLI in a herdr pane the user can watch: workers in their own worktree workspaces, scouts in the `agents` tab. You write packets, start agents, read results, merge, and clean up. Code changes go only to `worker`.

This skill only executes. The plan comes from a spec written with `quick-spec` or `type-spec` and split with `breakdown`. When the review is next, point to the `review` skill; do not run a reviewer here.

## Input

A spec in `<repo>/context/specs/` with a `## Validation` section and a `## Phases` section written by `breakdown`: one `### Phase N — <short-name>` per phase, with Wave, Depends on, Agent, Owns, Lands, Acceptance, and Gate.

Stop and point to the right skill when:

- the spec has no `## Phases` section: run `breakdown`;
- Validation fails "Complete or incomplete" in [../quick-spec/references/validation.md](../quick-spec/references/validation.md): fix it with `quick-spec` or `type-spec`;
- two phases in the same wave share an `Owns` path: send it back to `breakdown`.

## Preflight

Stop and report if any required check fails. Commands are in [references/launch.md](references/launch.md#preflight).

1. `HERDR_ENV=1`. Outside herdr there is no pane to start agents in.
2. The `worker` and `scout` agent files exist. `grok`, `pi`, and `agent-role` are needed only for a Grok or Pi scout; report the ones missing and stop only if the run needs them.
3. The repo has a working `verify-<app>` skill under `.claude/skills/`. If it is missing or broken, stop and point to `/create-verification-skill` or `/maintain-verification-skill`.
4. Create the run folder `<repo>/context/runs/<date>-<topic>/` and an empty `worktrees.txt`.
5. Create or reuse the `agents` tab in the current workspace. You stay alone in tab 1.
6. Run the stale-worktree check: list worktrees under `<repo>.worktrees/` older than 7 days and ask the user what to do with them before going on.

## Run the waves

Read [references/launch.md](references/launch.md) before starting the first agent, and [references/worktrees.md](references/worktrees.md) before creating the first worktree.

1. **Integration worktree.** Create `<repo>.worktrees/<topic>-run` on branch `<topic>/run` from the current HEAD. You merge here, never by switching branches in the main checkout, which other sessions use.
2. **Per phase in the wave.** Create its worktree on `<topic>/<phase-short-name>` from `<topic>/run`, record it in `worktrees.txt`, write its packet from [references/worker-packet.md](references/worker-packet.md), start `worker` in the workspace's root pane, and prompt: "Read the packet at `<path>` and do what it says."
3. **Wait** for every worker in the wave, in the order in [launch.md](references/launch.md#wait-and-read-back). A `blocked` agent is a stop: read the pane, then report.
4. **Read each result file** before acting on it. Check the claims that matter against the branch: the commit exists, the diff stays inside Owns, and the gate's evidence is there. Say plainly when a result is wrong or thin.
5. **Gate.** A phase passes when every Gate item has evidence: `verify-<app>` artifacts, command output, and exit codes, plus the fail-first check failing before and passing after. No evidence means not done. On a failure, send the same worker a new packet that quotes what failed. A second failure is a stop.
6. **Merge** each passing phase branch into `<topic>/run` in the integration worktree. Resolve conflicts yourself when you understand both sides; stop and report when you are not sure.
7. **Remove** each merged phase's worktree, as in [worktrees.md](references/worktrees.md#removing-a-worktree).
8. Start the next wave from the updated `<topic>/run` without checking in.

Use the fewest agents that finish. Send a scout only when a read-only question stands between you and the next step, such as where a conflicting caller lives. Packets are self-contained: quote the evidence, never "continue the work".

## Stops

Report to the user and wait when:

- a packet's Stop if hits;
- a phase fails its gate twice after re-dispatch;
- `verify-<app>` is missing or broken;
- a pane shows a trust or approval prompt (never send keys to it);
- a worker reports a blocked or destructive action;
- a merge conflict you cannot resolve with confidence.

Otherwise read each wave's results and dispatch the next wave without checking in. Continuing never overrides confirmation for risky or destructive actions: those still need the user's yes.

## Finish

1. Run the cleanup sweep in [worktrees.md](references/worktrees.md#cleanup-sweep). It removes every listed worktree and the phase branches; `<topic>/run` stays as the result.
2. Tell the user what changed per phase, the files, the checks and their results, the evidence paths in the run folder, and what is unresolved. Results in the run folder are not shown to the user.
3. Point to the spec path and to `review` for `<base>..<topic>/run`.
