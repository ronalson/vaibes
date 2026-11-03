# Worker packet

Read this when writing a worker packet. Save it as `<run folder>/phase-<N>-<short-name>-packet.md`. The worker starts with no access to this conversation, so the packet holds everything it needs. Quote the phase and any evidence; never write "continue the work".

The `worker` agent file holds the result-file template, so the packet names only the result path.

```markdown
# Packet: phase <N> — <short-name>

## Goal

<The phase's Lands line, and why it matters to the spec's goal.>

## Use

- Worktree: `<repo>.worktrees/<topic>-<short-name>`, on branch `<topic>/<short-name>` from `<topic>/run`. Commit there.
- Spec: `<repo>/context/specs/<spec>.md`. Read its Goal, Approach, and Validation.
- Phase, quoted from the spec:

  <the whole `### Phase N` block, including Acceptance and Gate>

- `verify-<app>`: `.claude/skills/verify-<app>/`. If the Gate lists Feature map IDs, run those journeys and keep the artifacts.
- <Anything earlier waves changed that this phase relies on, with paths and commit SHAs.>

## Own

<The phase's Owns paths, exactly.>

## Do not

- Edit files outside Own, including other phases' files.
- Push, merge, rebase, or switch branches.
- Commit anything under `context/`.

## Return

Write `<run folder>/phase-<N>-<short-name>-result.md`. For every Gate item that is not `None`, give its evidence: Commands with output and exit codes, the fail-first check failing before the change and passing after, and `verify-<app>` artifact paths for Feature map IDs. No evidence means the phase is not done.

## Stop if

- The phase needs a change outside Own.
- A Gate command or listed `verify-<app>` journey cannot run, or fails for a reason outside this phase.
- The work needs a destructive action or an approval.
```

## Re-dispatch

When a gate fails, write `phase-<N>-<short-name>-packet-2.md` with the same fields. Add to Use the failing items, quoted from the result file or from your own run, and what you expect instead. Prompt the same worker with the new path. A second failure is a stop.

## Read-only packets

Scouts need only Goal, Use, Return, and Stop if. Ask one specific question, give the paths you already know, and name the return format, such as a cited list of `file:line` locations.
