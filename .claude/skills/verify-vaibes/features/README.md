# vaibes workflow verification map

This directory is the maintained source for verifying the vaibes workflow skills against dry-vaibes. Read this index before driving a journey, then use the matching feature file as the recipe.

## Baseline preconditions

- A fresh run exists: `H=.claude/skills/verify-vaibes/scripts/vaibes-verify.sh; $H start` printed a `RUN_DIR`.
- `$H doctor "$RUN_DIR"` prints `doctor: healthy`.
- The run checkout is a detached worktree at dry-vaibes `main` with the fixture specs in `context/specs/`, there are no `clear/*` branches, and the run dir holds no other worktree. That is the state every journey starts from unless its preconditions say otherwise.
- Never run a journey in your own dry-vaibes checkout or in a run checkout another run created.

## Driving conventions

- Drive each skill through `$H agent "$RUN_DIR" <step> <skill> <instructions>`, and record the result with `$H state "$RUN_DIR" <step>` right after.
- Name the spec in the instructions by its path relative to the run checkout.
- Treat every expected file, heading, and status line as literal.
- Give each step a short descriptive name. Evidence files are numbered in run order.

## Proof and skip reporting

- Session proof is the step's `.result.md`, `.denials.json`, and `.code`, checked against the next `state` step.
- A journey passes only when the state shows what the feature file expects. The session's own summary is a claim, not proof.
- A non-empty `.denials.json` fails the journey. Report the denied call.
- Report an unreachable journey with the missing precondition, such as "not inside herdr".
- Do not report a journey for one runtime as proof for another.

## Feature entry contract

Each feature file starts with an H1 title, one paragraph describing the behavior, and a `Writes:` line naming what the skill changes in the run checkout. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists how a user starts the skill.
3. `Driving it with vaibes-verify.sh` starts with `Preconditions:` and uses labeled bullets that pair each action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a run.

## Features

- [Break down a spec](./breakdown.md) covers writing phases into a spec with complete Validation.
- [Delegate a spec](./delegate.md) covers a one-phase run under herdr, from worktree to merged run branch and cleanup.
- [Review a run](./review.md) covers a reviewer pass on a run branch and the verdict report.
