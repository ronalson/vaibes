# Review a run

Review hands a branch diff to a read-only reviewer from another model family, checks each finding against the code and every Validation and Gate item for evidence, and writes a report with a merge or fix verdict. It never edits code or branches.

Writes: `review-report.md` and the reviewer's findings in the run folder, and possibly a detached review worktree, which it removes. No branch or commit changes.

## Sub-features

- `review-verdict` writes `review-report.md` with every finding marked confirmed or rejected, every Validation and Gate item marked covered or missing, and a `merge` or `fix` verdict.
- `review-readonly` leaves every branch at the commit it had before the review.

## How to get to it (user POV)

- Run `/review <base>..<head>` in a session in the target repo, inside a herdr pane, after `delegate`.

## Driving it with vaibes-verify.sh

Preconditions:

- The `delegate-herdr` journey passed in this run, so `clear/run` and its run folder exist. Without it, report the journey as unreachable: "no run branch".
- `doctor` prints `info herdr: inside herdr, server running`, and `agent-role` and `grok` are on `PATH`.
- This journey starts a Grok reviewer session. Confirm with the user before running it unless they already asked for this journey.

- **Before.** Run `$H state "$RUN_DIR" before-review` and keep its `## branches` section.
- **Review.** Run `$H agent "$RUN_DIR" review review "Range: main..clear/run. Spec: context/specs/clear-command.md. Run folder: the one delegate created under context/runs/."` in the background, and wait for it to exit. Exit `0`, `.denials.json` is `[]`, and `.result.md` states the verdict.
- **After.** Run `$H state "$RUN_DIR" after-review`. `## branches` matches `before-review` exactly, and `## git worktree list` shows only the clone itself.
- **Proof.** In `NN-after-review.context/runs/<date>-clear/`, `review-report.md` and `reviewer-findings.md` exist. The report names the reviewer's tool and model, marks each finding confirmed or rejected with a reason, marks each Validation and Gate item covered or missing, and ends with `merge` or `fix`.

## Gotchas

- The verdict can be `fix` on a correct run if the reviewer finds a real gap. The journey proves the review ran and reported, not that the code is perfect.
- A Grok trust prompt in a fresh clone stops the reviewer. That is reported as a stop and fails the journey; the prompt goes in the report.
- `state` copies only `context/`. The review worktree, if any, must already be gone; check `## git worktree list`.
