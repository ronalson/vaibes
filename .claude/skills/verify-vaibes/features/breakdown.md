# Break down a spec

Breakdown reads a spec with a complete Validation section and appends a `## Phases` section that `delegate` can run: a wave plan and one H3 per phase with the fields `delegate` reads.

Writes: the spec file it is given. Nothing else in the clone.

## Sub-features

- `breakdown-phases` appends `## Phases` with a wave plan and, per phase, Wave, Depends on, Agent, Owns, Lands, Acceptance, and Gate, in that order.
- `breakdown-gate-copied` fills each Gate from the spec's Validation items, with at least one Commands entry or Feature map ID.
- `breakdown-no-verify-note`: in a repo without a `verify-<app>` skill, the hand-off says the phases are gated on Commands only and names `/create-verification-skill`.

## How to get to it (user POV)

- Run `/breakdown <spec path>` in a session in the target repo.
- Ask an agent to break down a spec in `context/specs/`.

## Driving it with vaibes-verify.sh

Preconditions:

- Baseline from `README.md`.

- **Break down.** Run `$H agent "$RUN_DIR" breakdown breakdown "Spec: context/specs/clear-command-unphased.md."`. Exit `0`, `.denials.json` is `[]`, and `.result.md` hands back the spec path.
- **State.** Run `$H state "$RUN_DIR" after-breakdown`. `## status` and `## branches` show no change: the spec is under the ignored `context/`, and only `main` exists.
- **Phases written.** In `NN-after-breakdown.context/specs/clear-command-unphased.md`, a `## Phases` heading follows `## Validation`, followed by a `Wave 1:` line and at least one `### Phase 1 — <name>` heading. Under each phase heading, the bullets `Wave:`, `Depends on:`, `Agent: worker`, `Owns:`, `Lands:`, `Acceptance:`, and `Gate:` appear in that order. Check with `grep -nE '^## Phases|^Wave [0-9]+:|^### Phase|^- (Wave|Depends on|Agent|Owns|Lands|Acceptance|Gate):' <file>`.
- **Gate copied.** Each `Gate:` has the five labels `Feature map`, `Commands`, `Fail-first`, `Review risks`, and `Manual checks`, and its Commands include `npm test`.
- **Proof.** Diff the spec against the fixture, ignoring blank lines: `diff -B <(sed '/^## Phases$/,$d' .claude/skills/verify-vaibes/fixtures/clear-command.md) <(sed '/^## Phases$/,$d' <copied spec>)` prints nothing, so breakdown changed only by appending.

`breakdown-no-verify-note` runs the same steps on a run made with `$H start --no-verify`, whose clone has no `.claude/skills/` and whose specs come from `fixtures/clear-command-no-verify.md`:

- **Break down.** As above. `.result.md` also has a line saying the phases are gated on Commands only, and it names `/create-verification-skill`.
- **Phases written.** As above, except each `Gate:` has no Feature map IDs and its Commands include `npm test`.
- **Proof.** As above, diffing against `fixtures/clear-command-no-verify.md`.

## Gotchas

- The phase count and names vary between runs. A one-phase or two-phase split can both be right; judge the fields and the gate, not the count.
- If breakdown says Validation is incomplete, the journey fails, and its reason belongs in the fixture: fix the fixture, not the expectation.
- `.result.md` may summarize phases that are not in the file. Only the copied spec counts.
- Breakdown may add a blank line before `## Phases`. That is why the proof diff uses `-B`.
