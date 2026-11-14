---
name: verify-vaibes
metadata:
  internal: true
description: Prove the vaibes workflow skills (breakdown, delegate, review) work by running this checkout's versions in fresh headless Claude sessions against a throwaway clone of the dry-vaibes tasks CLI, and capture each session's stream, result, and what it left in git. Use to prove a change to those skills, or to run a journey a spec's Feature map lists.
---

# verify-vaibes

The app under test is the set of workflow skills in `skills/`, and its user is an agent following them. Each journey starts a fresh `claude -p` session in a throwaway clone of [dry-vaibes](https://github.com/ronalson/dry-vaibes), a small Node task-list CLI with its own `verify-tasks` skill. The session follows `skills/<name>/SKILL.md` from this checkout, not the installed copy, so a branch can be proven before it is installed. The helper `scripts/vaibes-verify.sh` creates the clone, starts the sessions, and records evidence.

Read `features/README.md` and the feature file for what you are proving before you drive anything.

## Launch

Requirements: Node 22 or later, `claude`, `git`, `python3`, and read access to the private dry-vaibes repo over SSH. Journeys need more; each feature file lists its own.

```bash
H=.claude/skills/verify-vaibes/scripts/vaibes-verify.sh   # from the vaibes repo root
$H start                     # or: $H start my-run-id
# -> RUN_DIR=/…/verify-vaibes/20261114-101500-4242
```

`start` clones dry-vaibes (`DRY_VAIBES_REPO`, default `git@github.com:ronalson/dry-vaibes.git`; `DRY_VAIBES_REF`, default `main`) into `RUN_DIR/dry-vaibes`, removes its remote so nothing can be pushed, and installs two copies of the fixture spec from `fixtures/clear-command.md` in its `context/specs/`: `clear-command.md` with phases and `clear-command-unphased.md` without them. Set `DRY_VAIBES_REPO` to a local dry-vaibes checkout to skip the network; the clone takes its `main`, not your working tree.

Set `VERIFY_VAIBES_ROOT` to choose where runs go. The default is `${TMPDIR:-/tmp}/verify-vaibes`. When you have a session scratchpad, use it. Shell variables don't persist between tool calls, so pass the printed `RUN_DIR` explicitly to every later command.

Ready means `doctor` prints `doctor: healthy`. Each run has its own clone and worktree folder, so runs can go side by side, but two `delegate` journeys under herdr in the same herdr workspace share its `agents` tab.

## Doctor

```bash
$H doctor "$RUN_DIR"
```

Read-only. It fails on a missing requirement: Node 22, `claude`, the skills under test, the installed `worker` and `scout` agent files, a clone with a remote, or a clone whose `npm test` fails. It prints `info` lines for optional tools (herdr, `agent-role`, `grok`, `t3`, `pi`) without failing. Run it first, and again whenever a journey looks wrong.

## Drive

```bash
$H agent "$RUN_DIR" <step> <skill> [instructions...]
$H state "$RUN_DIR" <step>
```

`agent` runs, in the clone:

```bash
claude -p --permission-mode auto --permission-prompts none --strict-mcp-config \
  --disallowedTools Skill --add-dir <vaibes>/skills --add-dir <run-dir> \
  --output-format stream-json --verbose "<prompt>"
```

The prompt tells the session to follow `<vaibes>/skills/<skill>/SKILL.md` and every file it links, never an installed skill, and to report instead of asking the user. `--disallowedTools Skill` keeps the installed copy from loading. `--permission-prompts none` denies anything that would prompt, so a session never hangs. The trailing instructions name the spec and anything else the journey needs, for example `Spec: context/specs/clear-command-unphased.md.`

`agent` blocks until the session exits. A `delegate` journey takes many minutes, so run that call in the background and wait for it to finish.

`state` records what the run left behind: worktrees, branches, commits since the clone's base, `git status`, the files under `context/runs/`, and herdr workspaces inside the run dir. It also copies the clone's `context/` into the evidence.

Do not drive a journey by doing the skill's steps yourself, by editing the clone's spec or branches to fake a skill's output, or by invoking the installed skill. The proof is a fresh session following the file under test.

## Evidence

Every `agent` step writes `RUN_DIR/evidence/NN-<step>.{prompt,jsonl,err,code,result.md,denials.json}`: the prompt, the full stream, stderr, the exit code, the final `result` text, and the permission denials. The helper prints the exit code, result subtype, turn count, cost, and denial count. Every `state` step writes `NN-<step>.state.txt` and `NN-<step>.context/`. Each step is appended to `RUN_DIR/evidence/transcript.md`.

Proof standards:

- Exercise the real path: a fresh session following the skill file under test. Your own reading of the skill does not count.
- Judge the outcome from what the session left, not from what it says it did. Its claims in `result.md` are checked against `state.txt` and the copied `context/`.
- A non-empty `denials.json` means the session was blocked, whatever the exit code. Report the denied tool and input; do not count the journey as passed.
- An exit code of 0 is not success. A skill that stopped and reported, when the journey expects it to finish, is a failure with that report as evidence.
- Isolation is part of the proof. The clone has no remote, and `state` shows only branches and worktrees inside the run dir. Anything the session changed outside the run dir fails the run.

When you report, cite the evidence directory and the step files that prove each claim, and the cost the helper printed.

## Cleanup

```bash
$H cleanup "$RUN_DIR"
```

It records a final `cleanup-before` state, closes herdr workspaces whose checkout is inside this run dir, and deletes the clone and its worktree folder. It never deletes `RUN_DIR/evidence/`. Run it after failed attempts too. It does not close panes a journey opened in another workspace's `agents` tab; the `state` step lists what it can see, and closing a leftover pane is reported to the user, not done by name. Once cleanup has run, check that `ls "$RUN_DIR/evidence"` still lists the step files.

## Helpers

- `scripts/vaibes-verify.sh`: run with no args to print its usage. Subcommands are `start [run-id]`, `doctor <run-dir>`, `agent <run-dir> <step> <skill> [instructions...]`, `state <run-dir> <step>`, and `cleanup <run-dir>`. It needs bash, git, node, npm, python3, and claude, and herdr only for the herdr workspace listing.
- `fixtures/clear-command.md`: a complete one-phase spec for a `clear` command in dry-vaibes, with Validation and Phases. Journeys use it so that their outcome does not depend on an earlier journey.

## Feature map

`features/README.md` indexes one file per workflow skill, with the journey that proves it. A skill under `skills/` that the workflow uses but the map lacks is a gap; `handoff` and `type-spec` are not covered because they interview the user.
