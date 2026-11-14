# Add a clear command

## Goal

Let a user remove every done task in one step with `tasks clear`, so the list stays short without removing tasks one by one.

## Scope

In scope: a `clear` command, its test, and its verify-tasks feature file and rules.

Out of scope: clearing open tasks, confirmation prompts, and undo.

## Approach

Add `src/commands/clear.js`, which follows the one-file-per-command pattern in `src/cli.js`. It loads the store, keeps only tasks with `done: false`, saves, and prints `Cleared <n> done tasks`. It never changes `nextId`, so ids are not reused. With no done tasks it prints `Cleared 0 done tasks` and leaves the store byte-for-byte unchanged, including not creating a missing store.

## Files

- `src/commands/clear.js` (new): `summary` is `clear        Remove done tasks`; `run()` as in Approach.
- `test/clear.test.js` (new): tests `clear removes only done tasks`, `clear keeps ids increasing`, and `clear with nothing done leaves the store alone`.
- `.claude/skills/verify-tasks/features/clear.md` (new): the `clear-done`, `clear-none`, and `clear-ids` sub-features.
- `.claude/skills/verify-tasks/features/README.md`: list `clear.md` under Features. Line 16 ("Create state only through `add` and `done`") is `not affected`: clear removes state, it does not create it.
- `.claude/skills/verify-tasks/SKILL.md`: lines 70 and 71 list the commands that may change the store; add `clear` to both. Line 61 is `not affected`, for the same reason as README line 16.

## Acceptance criteria

- `tasks clear` removes every done task, keeps open tasks in order, and prints `Cleared <n> done tasks`.
- A task added after `clear` gets the next id, never a cleared one.
- `clear` with nothing done leaves the store untouched.
- `tasks help` lists `clear`.

## Validation

### Feature map

- `verify-tasks`: `help.md` → `help-complete`
- `verify-tasks`: `list.md` → `list-items`
- `verify-tasks`: `add.md` → `add-next`
- New, added by this work: `clear.md` → `clear-done`, `clear-none`, `clear-ids`.
- Search: `` grep -rn -e 'add` and `done' -e '`add`, `done`' .claude/skills/verify-tasks/ ``. Each match is listed in Files with its change or marked `not affected`.

### Commands

- `npm test` (from `package.json` `scripts.test`, which runs `node --test`)
- `H=.claude/skills/verify-tasks/scripts/tasks-verify.sh; $H start`, then `$H doctor "$RUN_DIR"`, `$H cli "$RUN_DIR"` steps such as `$H cli "$RUN_DIR" clear-1 -- clear`, and `$H cleanup "$RUN_DIR"` (from `.claude/skills/verify-tasks/SKILL.md`), driving the journeys in `features/clear.md` and `features/help.md`

### Fail-first

- `npm test` fails before the change: `test/clear.test.js` gets `tasks: unknown command 'clear'` with exit 1 because `src/commands/clear.js` does not exist. It passes after.
- The verify-tasks `help.md` step for `help-complete` fails before the change because stdout has no `clear` line, and passes after.

### Review risks

- **Id reuse after clear.** Recomputing `nextId` from the remaining tasks hands a cleared id to a new task. Caught by: `clear keeps ids increasing` (adds three, completes `#3`, clears, then expects `Added #4`), and the `clear-ids` journey step.
- **Clear writing the store when nothing changed.** Saving unconditionally creates a missing store. Caught by: `clear with nothing done leaves the store alone` (no store file after `clear` on an empty store), and the `clear-none` journey's `.store.json` comparison.

### Manual checks

None

## Phases

Wave 1: phase 1

### Phase 1 — clear
- Wave: 1
- Depends on: nothing
- Agent: worker
- Owns: `src/commands/clear.js`, `test/clear.test.js`, `.claude/skills/verify-tasks/features/clear.md`, `.claude/skills/verify-tasks/features/README.md`, `.claude/skills/verify-tasks/SKILL.md`
- Lands: `tasks clear` removes done tasks, keeps ids increasing, and appears in `tasks help`.
- Acceptance:
  - `tasks clear` removes every done task, keeps open tasks in order, and prints `Cleared <n> done tasks`.
  - A task added after `clear` gets the next id, never a cleared one.
  - `clear` with nothing done leaves the store untouched.
  - `tasks help` lists `clear`.
  - Tests `clear removes only done tasks`, `clear keeps ids increasing`, and `clear with nothing done leaves the store alone`.
- Gate:
  - Feature map: `help.md` → `help-complete`; `list.md` → `list-items`; `add.md` → `add-next`; `clear.md` → `clear-done`, `clear-none`, `clear-ids`
  - Commands: `npm test` (from `package.json`); the verify-tasks helper steps (from `.claude/skills/verify-tasks/SKILL.md`)
  - Fail-first: `test/clear.test.js` fails before the change with `tasks: unknown command 'clear'`; the `help-complete` step has no `clear` line before the change
  - Review risks: id reuse after clear. Caught by: `clear keeps ids increasing` and the `clear-ids` step. Clear writing the store when nothing changed. Caught by: `clear with nothing done leaves the store alone` and the `clear-none` step.
  - Manual checks: None
