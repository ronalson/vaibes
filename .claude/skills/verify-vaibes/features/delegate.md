# Delegate a spec

Delegate runs a phased spec: it creates an integration worktree, starts a worker per phase in its own worktree, gates each result, merges passing phases into `<topic>/run`, and cleans up the phase worktrees and branches.

Writes: in the clone, the `<topic>/run` branch and its commits, a run folder under `context/runs/`, and temporary worktrees under `dry-vaibes.worktrees/`, which cleanup removes. Under herdr, also temporary workspaces and panes.

## Sub-features

- `delegate-herdr` finishes a one-phase run under herdr: a `done` result file, the phase merged into `<topic>/run`, and no phase worktrees or phase branches left.
- `delegate-gate-evidence` leaves the phase's gate evidence in the run folder: `npm test` output with its exit code and the verify-tasks journey evidence the gate lists.

## How to get to it (user POV)

- Run `/delegate <spec path>` in a session in the target repo, inside a herdr pane.

## Driving it with vaibes-verify.sh

Preconditions:

- Baseline from `README.md`.
- `doctor` prints `info herdr: inside herdr, server running`. Otherwise report the journey as unreachable: "not inside herdr".
- The installed `worker` agent file is the one the change under test expects. `doctor` checks it exists, not its version; compare it with `claude-agents/worker.md` when the change touches it.
- This journey starts real worker agents and costs a full worker session. Confirm with the user before running it unless they already asked for this journey.

- **Delegate.** Run `$H agent "$RUN_DIR" delegate delegate "Spec: context/specs/clear-command.md. Use topic clear."` in the background, and wait for it to exit. Exit `0`, `.denials.json` is `[]`, and `.result.md` reports phase 1 as done and points to `review` for `<base>..clear/run`.
- **State.** Run `$H state "$RUN_DIR" after-delegate`. `## git worktree list` shows only the clone itself. `## branches` shows `main` and `clear/run`, and no `clear/<phase>` branch. `## log since base` shows the phase commit and a merge commit on `clear/run`. `## herdr workspaces in this run` is empty.
- **Result file.** In `NN-after-delegate.context/runs/<date>-clear/`, the phase result file's first status line is `**Status:** done`, and `worktrees.txt` marks every entry `# removed: `.
- **Gate evidence.** The result file lists `npm test` with its output and exit code, and verify-tasks evidence paths for the gate's Feature map IDs.
- **Proof.** Run `git -C "$RUN_DIR/dry-vaibes" switch clear/run` then `$H state "$RUN_DIR" on-run-branch`, and run `node src/cli.js help` in the clone. The help lists `clear`. Switch back with `git -C "$RUN_DIR/dry-vaibes" switch main`.

## Gotchas

- `agent` blocks until the session exits, often 10 minutes or more. Start it in the background, not in a foreground call with a short timeout.
- Under herdr, the session creates the `agents` tab in the herdr workspace you started it from. Cleanup closes only workspaces inside the run dir, so close that tab yourself only if this run created it.
- A worker that stops on a trust or approval prompt leaves the run waiting. The session reports it as a stop; that is a failed journey, and the prompt goes in the report.
- The run folder's date comes from the session's clock. Find it with `ls`, not by building the name.
