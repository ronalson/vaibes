# Worktrees, merging, and cleanup

Read this before creating the first worktree of a run, and again before the cleanup sweep.

## Rules

- Location: use the worktree folder the machine's own instructions give, after any check they require before writing there, such as a mount check. Otherwise use `<repo>.worktrees/`, next to the repo. This page calls it `<worktree folder>`; each worktree is `<worktree folder>/<topic>-<phase-short-name>`. A runtime that chooses its own path reports it; record that path, not the one you expected.
- Create and remove worktrees through the runtime's Workspace operation ([runtimes/contract.md](runtimes/contract.md#operations)). Use the plain `git worktree` commands below when the runtime has none or cannot.
- Record every worktree the run creates in `<run folder>/worktrees.txt`, one line each: the runtime's workspace handle, path, branch. Use `-` for the handle of a plain `git worktree`. Cleanup touches only listed entries.
- Never pass `--force`, never remove a worktree with uncommitted changes, and never remove one that is not listed, without asking.

## Stale-worktree check

At the start of each run, list worktrees older than 7 days and ask the user what to do with them:

```bash
find <worktree folder> -mindepth 1 -maxdepth 1 -type d -mtime +7
git -C <repo> worktree list
```

Add the runtime's own listing when its Workspace operation has one.

## Creating a worktree

Use the runtime's Workspace operation. Without one, use plain git:

```bash
git -C <repo> worktree add -b <topic>/<phase> <path> <ref>
```

The integration worktree is created the same way with `<phase>` set to `run` and the base set to the current HEAD. Phase worktrees use `<topic>/run` as the base, so each wave starts from the merged result of the waves before it.

## Merging

Merge in the integration worktree, one phase branch at a time:

```bash
git -C <integration worktree> merge --no-ff <topic>/<phase>
```

On a conflict, read both sides and the two phases' Lands and Acceptance lines. Resolve it when you understand what both sides intended, commit, and note the resolution for the user. When you are not sure, run `git -C <integration worktree> merge --abort` and report the conflicting files and both phases.

After a wave merges, run the gate Commands that cover more than one phase in the integration worktree, so a clean merge that breaks behavior is caught before the next wave.

## Removing a worktree

Remove a phase's worktree once its branch is merged and its result file is in the run folder. Remove a failed phase's worktree once it is reported, unless the user asks to inspect it.

```bash
git -C <worktree> status --porcelain     # must be empty
```

Then remove it with the runtime's Workspace operation, or `git -C <repo> worktree remove <path>` for a `-` entry. Either keeps the branch and the worktree folder. Then prefix its line in `worktrees.txt` with `# removed: ` so the sweep skips it.

## Cleanup sweep

At the end of the run, for each line in `worktrees.txt` that does not start with `# removed: `:

1. Skip and report any worktree with uncommitted changes.
2. Remove the worktree as in [Removing a worktree](#removing-a-worktree). Mark the line `# removed: `.

Then delete the phase branches. They were merged into `<topic>/run`, not into the main checkout's branch, so `git branch -d` would refuse them all. Check the merge against `<topic>/run` instead, and use `-D` only on branches that check lists:

```bash
git -C <repo> branch --merged <topic>/run --list '<topic>/*'
git -C <repo> branch -D <topic>/<phase>     # each listed branch except <topic>/run
```

Keep `<topic>/run`; it holds the result for review. Report any `<topic>/*` branch not in the merged list and ask before deleting it, since the work may be wanted. Then:

```bash
rmdir <worktree folder>         # only when the run created it and it is empty
git -C <repo> worktree prune
```

Finish by listing `git -C <repo> worktree list` and `git -C <repo> branch --list '<topic>/*'` so the report shows what is left.
