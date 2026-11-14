---
name: verify-vaibes
metadata:
  internal: true
description: Prove the vaibes workflow skills (breakdown, delegate, review) work by running this checkout's versions in fresh headless Claude sessions against a throwaway worktree of the dry-vaibes tasks CLI, and capture each session's stream, result, and what it left in git. Use to prove a change to those skills, or to run a journey a spec's Feature map lists.
---

# verify-vaibes

The app under test is the set of workflow skills in `skills/`, and its user is an agent following them. Each journey starts a fresh `claude -p` session in a throwaway worktree of [dry-vaibes](https://github.com/ronalson/dry-vaibes), a small Node task-list CLI with its own `verify-tasks` skill. The session follows `skills/<name>/SKILL.md` from this checkout, not the installed copy, so a branch can be proven before it is installed. The helper `scripts/vaibes-verify.sh` creates the worktree, starts the sessions, and records evidence.

Read `features/README.md` and the feature file for what you are proving before you drive anything.

## Launch

Requirements: Node 22 or later, `claude`, `git`, `python3`, and a local dry-vaibes checkout that you have opened Claude in once, so Claude trusts it. Journeys need more; each feature file lists its own.

```bash
H=.claude/skills/verify-vaibes/scripts/vaibes-verify.sh   # from the vaibes repo root
$H start                     # or: $H start my-run-id, $H start --no-verify [run-id]
# -> RUN_DIR=/…/verify-vaibes/20261114-101500-4242
```

`start` adds a detached worktree of the local dry-vaibes checkout (`DRY_VAIBES_DIR`, default `dry-vaibes` next to the main vaibes checkout) at `DRY_VAIBES_REF` (default its local `main`, not your working tree) as `RUN_DIR/dry-vaibes`, and installs two copies of the fixture spec from `fixtures/clear-command.md` in its `context/specs/`: `clear-command.md` with phases and `clear-command-unphased.md` without them.

A worktree, not a clone, because workers under herdr are interactive Claude sessions: in a folder Claude does not trust they stop on the folder-trust screen, which only the user may answer. Worktrees of a trusted repo are trusted, and so are the worktrees `delegate` adds to them, so the user never approves a run's folders. The cost is that the run's branches live in that checkout. Every journey uses the topic `clear`, so `start` refuses while `clear/*` branches exist there, and `cleanup` deletes them. That makes it one run at a time per dry-vaibes checkout.

`start --no-verify` makes a run checkout without a `verify-<app>` skill, for the journeys that prove the skills work without one. It deletes `.claude/skills/verify-tasks/` and commits that on the detached HEAD, so no branch changes, and installs both spec copies from `fixtures/clear-command-no-verify.md` under the same names. `run.env` records which fixture the run used.

Set `VERIFY_VAIBES_ROOT` to choose where runs go. The default is `~/.cache/verify-vaibes`. Shell variables don't persist between tool calls, so pass the printed `RUN_DIR` explicitly to every later command.

Ready means `doctor` prints `doctor: healthy`.

## Doctor

```bash
$H doctor "$RUN_DIR"
```

Read-only. It fails on a missing requirement: Node 22, `claude`, the skills under test, the installed `worker` and `scout` agent files, a run checkout that is not a worktree of the dry-vaibes checkout, or one whose `npm test` fails. It prints `info` lines for optional tools (herdr, `agent-role`, `grok`, `t3`, `pi`) and for whether Claude trusts the dry-vaibes checkout, without failing. Run it first, and again whenever a journey looks wrong.

## Drive

```bash
$H agent "$RUN_DIR" <step> <skill> [instructions...]
$H state "$RUN_DIR" <step>
```

`agent` runs, in the run checkout:

```bash
claude -p --permission-mode auto --permission-prompts none --strict-mcp-config \
  --disallowedTools Skill --add-dir <vaibes>/skills --add-dir <run-dir> \
  --output-format stream-json --verbose "<prompt>"
```

The prompt tells the session to follow `<vaibes>/skills/<skill>/SKILL.md` and every file it links, never an installed skill, and to report instead of asking the user. `--disallowedTools Skill` keeps the installed copy from loading. `--permission-prompts none` denies anything that would prompt, so a session never hangs. The trailing instructions name the spec and anything else the journey needs, for example `Spec: context/specs/clear-command-unphased.md.`

`agent` blocks until the session exits. A `delegate` journey takes many minutes, so run that call in the background and wait for it to finish.

`state` records what the run left behind: the worktrees inside the run dir, the `clear/*` branches and their commits since the run's base, `git status`, the files under `context/runs/`, and herdr workspaces inside the run dir. The dry-vaibes checkout's other worktrees and branches are left out. It also copies the run checkout's `context/` into the evidence.

Do not drive a journey by doing the skill's steps yourself, by editing the run's spec or branches to fake a skill's output, or by invoking the installed skill. The proof is a fresh session following the file under test.

## Evidence

Every `agent` step writes `RUN_DIR/evidence/NN-<step>.{prompt,jsonl,err,code,result.md,denials.json}`: the prompt, the full stream, stderr, the exit code, the final `result` text, and the permission denials. The helper prints the exit code, result subtype, turn count, cost, and denial count. Every `state` step writes `NN-<step>.state.txt` and `NN-<step>.context/`. Each step is appended to `RUN_DIR/evidence/transcript.md`.

Proof standards:

- Exercise the real path: a fresh session following the skill file under test. Your own reading of the skill does not count.
- Judge the outcome from what the session left, not from what it says it did. Its claims in `result.md` are checked against `state.txt` and the copied `context/`.
- A non-empty `denials.json` means the session was blocked, whatever the exit code. Report the denied tool and input; do not count the journey as passed.
- An exit code of 0 is not success. A skill that stopped and reported, when the journey expects it to finish, is a failure with that report as evidence.
- Isolation is part of the proof. The session may add only `clear/*` branches and worktrees inside the run dir. Anything else it changed in the dry-vaibes checkout, or outside the run dir, fails the run. A push fails it too: the checkout has its remote, and only the packets' rules prevent pushing.

When you report, cite the evidence directory and the step files that prove each claim, and the cost the helper printed.

## Cleanup

```bash
$H cleanup "$RUN_DIR"
```

It records a final `cleanup-before` state, closes herdr workspaces whose checkout is inside this run dir, deletes the run checkout and its worktree folder, prunes them from the dry-vaibes checkout, and deletes its `clear/*` branches. It never deletes `RUN_DIR/evidence/`. Run it after failed attempts too. It does not close panes a journey opened in another workspace's `agents` tab; the `state` step lists what it can see, and closing a leftover pane is reported to the user, not done by name. Once cleanup has run, check that `ls "$RUN_DIR/evidence"` still lists the step files.

## Helpers

- `scripts/vaibes-verify.sh`: run with no args to print its usage. Subcommands are `start [--no-verify] [run-id]`, `doctor <run-dir>`, `agent <run-dir> <step> <skill> [instructions...]`, `state <run-dir> <step>`, and `cleanup <run-dir>`. It needs bash, git, node, npm, python3, and claude, and herdr only for the herdr workspace listing.
- `fixtures/clear-command.md`: a complete one-phase spec for a `clear` command in dry-vaibes, with Validation and Phases. Journeys use it so that their outcome does not depend on an earlier journey.
- `fixtures/clear-command-no-verify.md`: the same `clear` spec for a repo without a verify skill. Its Feature map says so, and its gate runs `npm test` only. `start --no-verify` installs it.

## Feature map

`features/README.md` indexes one file per workflow skill, with the journey that proves it. A skill under `skills/` that the workflow uses but the map lacks is a gap; `handoff` and `type-spec` are not covered because they interview the user.
