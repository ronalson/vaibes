# Add a clear command

## Goal

Let a user remove every done task in one step with `tasks clear`, so the list stays short without removing tasks one by one.

## Scope

In scope: a `clear` command and its test.

Out of scope: clearing open tasks, confirmation prompts, and undo.

## Approach

Add `src/commands/clear.js`, which follows the one-file-per-command pattern in `src/cli.js`. It loads the store, keeps only tasks with `done: false`, saves, and prints `Cleared <n> done tasks`. It never changes `nextId`, so ids are not reused. With no done tasks it prints `Cleared 0 done tasks` and leaves the store byte-for-byte unchanged, including not creating a missing store.

## Files

- `src/commands/clear.js` (new): `summary` is `clear        Remove done tasks`; `run()` as in Approach.
- `test/clear.test.js` (new): tests `clear removes only done tasks`, `clear keeps ids increasing`, `clear with nothing done leaves the store alone`, and `help lists clear`.

## Acceptance criteria

- `tasks clear` removes every done task, keeps open tasks in order, and prints `Cleared <n> done tasks`.
- A task added after `clear` gets the next id, never a cleared one.
- `clear` with nothing done leaves the store untouched.
- `tasks help` lists `clear`.

## Validation

### Feature map

No verify skill (`.claude/skills/verify-*/`) in this repo. Run /create-verification-skill to add one.

### Commands

- `npm test` (from `package.json` `scripts.test`, which runs `node --test`)

### Fail-first

- `npm test` fails before the change: `test/clear.test.js` gets `tasks: unknown command 'clear'` with exit 1 because `src/commands/clear.js` does not exist. It passes after.

### Review risks

- **Id reuse after clear.** Recomputing `nextId` from the remaining tasks hands a cleared id to a new task. Caught by: `clear keeps ids increasing` (adds three, completes `#3`, clears, then expects `Added #4`).
- **Clear writing the store when nothing changed.** Saving unconditionally creates a missing store. Caught by: `clear with nothing done leaves the store alone` (no store file after `clear` on an empty store).

### Manual checks

None

## Phases

Wave 1: phase 1

### Phase 1 — clear
- Wave: 1
- Depends on: nothing
- Agent: worker
- Owns: `src/commands/clear.js`, `test/clear.test.js`
- Lands: `tasks clear` removes done tasks, keeps ids increasing, and appears in `tasks help`.
- Acceptance:
  - `tasks clear` removes every done task, keeps open tasks in order, and prints `Cleared <n> done tasks`.
  - A task added after `clear` gets the next id, never a cleared one.
  - `clear` with nothing done leaves the store untouched.
  - `tasks help` lists `clear`.
  - Tests `clear removes only done tasks`, `clear keeps ids increasing`, `clear with nothing done leaves the store alone`, and `help lists clear`.
- Gate:
  - Feature map: None
  - Commands: `npm test` (from `package.json`)
  - Fail-first: `test/clear.test.js` fails before the change with `tasks: unknown command 'clear'`
  - Review risks: id reuse after clear. Caught by: `clear keeps ids increasing`. Clear writing the store when nothing changed. Caught by: `clear with nothing done leaves the store alone`.
  - Manual checks: None
