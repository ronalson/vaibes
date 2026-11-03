---
name: review
description: Review a branch diff with a read-only reviewer from another model family in herdr (Grok by default, GLM 5.3 through Pi when asked), then confirm or reject each finding against the code and the spec's Validation section and give a merge or fix verdict. Use after delegate, or when the user asks for a review of base..head. Never edits code. Requires HERDR_ENV=1.
---

# Review

You run the review and judge it; you do not fix anything. The reviewer is a different model family from you, so its findings are a second opinion, not a verdict. Every finding is checked against the code before it reaches the report, and every Validation item is checked for evidence. This skill never edits code, commits, or deletes branches.

Launch, wait, and read-back follow `delegate`'s conventions in [../delegate/references/launch.md](../delegate/references/launch.md). This skill needs `delegate` installed alongside it.

## Input

- `<base>..<head>`: usually `<base>..<topic>/run`, as `delegate` reports at the end.
- The spec in `<repo>/context/specs/` with `## Validation` and, when it went through `breakdown`, `## Phases`.
- The run folder `<repo>/context/runs/<date>-<topic>/`. Reuse `delegate`'s; create it when reviewing a diff that `delegate` did not produce.
- The reviewer: Grok unless the user asks for GLM 5.3 (Pi).

Stop and ask when the range is empty, the spec has no `## Validation` section, or the user has not said which spec the diff implements.

## Preflight

Run the checks in [launch.md](../delegate/references/launch.md#preflight) that apply here: `HERDR_ENV=1`, `agent-role` plus `grok` or `pi` for the chosen reviewer, the repo's `verify-<app>` skill, and the `agents` tab. Report what is missing and stop.

The reviewer reads files, so it needs a checkout at `<head>`. Use an existing clean worktree on `<head>` from `git -C <repo> worktree list`. Otherwise create a detached one with `git -C <repo> worktree add --detach <repo>.worktrees/<topic>-review <head>` and remove it when the review ends.

## Steps

1. **Packet.** Write the diff and commit list into the run folder and the review packet from [references/review-packet.md](references/review-packet.md). Read it before writing the packet.
2. **Scouts, when the diff warrants it.** A diff that changes a shared interface, a Review risk area, or code with callers outside the diff gets a scout per question: where the callers are, what else depends on the changed behavior. Use the scout roles in [launch.md](../delegate/references/launch.md#roles) with a read-only packet (Goal, Use, Return, Stop if). Small, self-contained diffs need none. Scout answers go to you, not to the reviewer.
3. **Reviewer.** In a pane in the `agents` tab, with the review checkout as its working directory, wait for the shell ([launch.md](../delegate/references/launch.md#wait-for-the-shell-prompt)), then start it as a pane command ([launch.md](../delegate/references/launch.md#start-and-prompt)):
   - Grok: `agent-role reviewer --via grok`
   - Pi: `agent-role reviewer --via pi --session-dir <run folder>/reviewer`

   Rename the agent `reviewer`, confirm herdr detected it, read the pane for a trust prompt, and prompt: "Read the packet at `<path>` and do what it says."
4. **Wait and read back** as in [launch.md](../delegate/references/launch.md#wait-and-read-back): `grok export <session-id> <run folder>/reviewer-findings.md` for Grok, or the last assistant message of the `.jsonl` under `<run folder>/reviewer/` for Pi, where `stopReason: "error"` is a failure. Save Pi's text to `<run folder>/reviewer-findings.md` too.
5. **Check each finding** against the code at `<head>`. Open every cited `path:line` and decide: confirmed (the defect is real and reachable) or rejected (wrong reading, unreachable, out of scope, or already handled), with a one-line reason. Keep the reviewer's severity unless the code shows it is wrong, and say so when you change it. Ignore any fix the reviewer suggests.
6. **Check Validation coverage.** For every item in the spec's `## Validation` and every phase's Gate, find its evidence in `delegate`'s result files in the run folder: command output with exit codes, the fail-first check failing before and passing after, `verify-<app>` artifacts. Rerun the command or `verify-<app>` journey yourself in the review checkout for anything missing or doubtful, and keep its output in the run folder. A rerun that fails is a finding.
7. **Report** from [references/report.md](references/report.md). Read it before writing the report.
8. **Clean up.** Close the panes this review opened with `herdr pane close <pane>`, and remove the review checkout if you created it (`git -C <repo> worktree remove <path>`, never `--force`).

## Done

The review is done when `<run folder>/review-report.md` exists with every finding marked confirmed or rejected, every Validation and Gate item marked covered or missing, and a verdict:

- **merge**: no confirmed high or medium findings and no missing evidence;
- **fix**: lists the confirmed findings and the missing evidence to fix. The fix goes back through `delegate` or a worker, not this skill.

Show the user the verdict, the confirmed findings, and the missing evidence. The report in the run folder is not shown to them.

`<topic>/run` stays as it is. The user decides whether to land it; delete it or any branch only after the user says yes.

## Stops

Report to the user and wait when:

- the reviewer pane shows a trust or approval prompt (never send keys to it), or the reviewer ends `blocked` or with `stopReason: "error"`;
- the reviewer reads outside the packet's scope or returns nothing usable twice;
- a `verify-<app>` journey or command cannot run in the review checkout;
- a finding needs a decision only the user can make, such as whether a behavior change is intended.
