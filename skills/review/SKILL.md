---
name: review
description: Review a branch diff with a read-only reviewer from another model family via `agent-role reviewer`, then confirm or reject each finding against the code and the spec's Validation section and give a merge or fix verdict. Use after delegate, or when the user asks for a review of base..head. Never edits code.
---

# Review

You run the review and judge it; you do not fix anything. The reviewer is a different model family from you, so its findings are a second opinion, not a verdict. Every finding is checked against the code before it reaches the report, and every Validation item is checked for evidence. This skill never edits code, commits, or deletes branches.

Roles, starting, waiting, and reading back follow `delegate`'s [roles](../delegate/references/roles.md) and [runtime contract](../delegate/references/runtimes/contract.md): the steps below name the contract's operations, and the chosen runtime's page gives their commands. This skill needs `delegate` installed alongside it.

## Input

- `<base>..<head>`: usually `<base>..<topic>/run`, as `delegate` reports at the end.
- The spec in `<repo>/context/specs/` with `## Validation` and, when it went through `breakdown`, `## Phases`.
- The run folder `<repo>/context/runs/<date>-<topic>/`. Reuse `delegate`'s; create it when reviewing a diff that `delegate` did not produce.
- The reviewer: `agent-role reviewer`'s default tool, unless the user asks for Pi (`--via pi`). Pi is not installed on every machine; use it only when `pi` is there.

Stop and ask when the range is empty, the spec has no `## Validation` section, or the user has not said which spec the diff implements.

## Preflight

1. Choose the runtime as in [Choosing a runtime](../delegate/references/runtimes/contract.md#choosing-a-runtime), and read its page. When it cannot run the reviewer, read the page of the runtime it names instead.
2. Run the checks in [roles.md](../delegate/references/roles.md#preflight) for the reviewer: `agent-role` and the tool it runs the reviewer with. Report what is missing and stop.
3. Run the runtime's Prepare operation, when its page has one.

The repo does not need a `verify-<app>` skill. Feature map journeys are rerun only when the spec lists them.

The reviewer reads files, so it needs a checkout at `<head>`. Use an existing clean worktree on `<head>` from `git -C <repo> worktree list`. Otherwise create a detached one with `git -C <repo> worktree add --detach <worktree folder>/<topic>-review <head>`, with the folder from [delegate's worktree rules](../delegate/references/worktrees.md#rules), and remove it when the review ends.

## Steps

1. **Packet.** Write the diff and commit list into the run folder and the review packet from [references/review-packet.md](references/review-packet.md). Read it before writing the packet.
2. **Scouts, when the diff warrants it.** A diff that changes a shared interface, a Review risk area, or code with callers outside the diff gets a scout per question: where the callers are, what else depends on the changed behavior. Use the scout roles in [roles.md](../delegate/references/roles.md#roles) with a read-only packet (Goal, Use, Return, Stop if). Small, self-contained diffs need none. Scout answers go to you, not to the reviewer.
3. **Reviewer.** Start it with the Start operation, with the review checkout as its working directory. When the chosen runtime cannot run the reviewer, start it where that runtime's page says.
   - Default: `agent-role reviewer`
   - Pi: `agent-role reviewer --via pi --session-dir <run folder>/reviewer`

   Name the agent `reviewer` and record it in `agents.txt`. Before the first prompt, check with the Read operation that it is not waiting on a trust prompt, then prompt: "Read the packet at `<path>` and do what it says."
4. **Wait and read back** with the Wait and Read operations, reading the answer as in [roles.md](../delegate/references/roles.md#reading-answers): `grok export <session-id> <run folder>/reviewer-findings.md` for Grok, with the ID from the `agent-role: grok session <id>` line, or the last assistant message of the `.jsonl` under `<run folder>/reviewer/` for Pi, where `stopReason: "error"` is a failure. Save Pi's text to `<run folder>/reviewer-findings.md` too.
5. **Check each finding** against the code at `<head>`. Open every cited `path:line` and decide: confirmed (the defect is real and reachable) or rejected (wrong reading, unreachable, out of scope, or already handled), with a one-line reason. Keep the reviewer's severity unless the code shows it is wrong, and say so when you change it. Ignore any fix the reviewer suggests.
6. **Check Validation coverage.** For every item in the spec's `## Validation` and every phase's Gate, find its evidence in `delegate`'s result files in the run folder: command output with exit codes, the fail-first check failing before and passing after, `verify-<app>` artifacts. Rerun the command or `verify-<app>` journey yourself in the review checkout for anything missing or doubtful, and keep its output in the run folder. A rerun that fails is a finding.
7. **Report** from [references/report.md](references/report.md). Read it before writing the report.
8. **Clean up.** Close the agents this review started with the Close operation, and remove the review checkout if you created it (`git -C <repo> worktree remove <path>`, never `--force`).

## Done

The review is done when `<run folder>/review-report.md` exists with every finding marked confirmed or rejected, every Validation and Gate item marked covered or missing, and a verdict:

- **merge**: no confirmed high or medium findings and no missing evidence;
- **fix**: lists the confirmed findings and the missing evidence to fix. The fix goes back through `delegate` or a worker, not this skill.

Show the user the verdict, the confirmed findings, and the missing evidence. The report in the run folder is not shown to them.

`<topic>/run` stays as it is. The user decides whether to land it; delete it or any branch only after the user says yes.

## Stops

Report to the user and wait when:

- the reviewer waits on a trust or approval prompt (never answer it), or the reviewer fails or ends with `stopReason: "error"`;
- the reviewer reads outside the packet's scope or returns nothing usable twice;
- a `verify-<app>` journey or command the spec lists cannot run in the review checkout;
- a finding needs a decision only the user can make, such as whether a behavior change is intended.
