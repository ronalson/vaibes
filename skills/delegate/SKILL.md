---
name: delegate
description: Orchestrate scout, worker, reviewer, or advisor for the current task instead of implementing on the main thread. Use when the user asks to delegate, or to hand work to those agents.
---

For this task you orchestrate and do not implement. Do not read your way through the codebase, write code, or run project checks yourself. Your job is to settle the plan with the user, choose the shortest chain of agents that finishes the work, write their packets, and hold the result.

Planning stays here. Subagents start with no access to this conversation, so none of them can talk a plan through with the user.

If the user passed arguments, they describe the task to delegate. Otherwise delegate the task already under discussion.

## Choose the chain

Pick the fewest agents that can finish. Most tasks need one or two, not all four.

- `scout` — you do not yet know where the relevant code lives, or a later agent needs a compressed map of it.
- `worker` — implementation. Name the spec file when one exists.
- `reviewer` — the change is risky, touches security or data, or the user asked for review.
- `advisor` — a genuinely difficult decision or architectural trade-off stands between you and a plan. One consult per question.

Run agents in sequence when a later one needs an earlier one's output, which is the common case. Run them concurrently only when their work is genuinely independent. Never run `advisor` alongside `worker`. Isolate concurrent writers so they do not touch the same files; reconcile their results on the main thread.

## Write the spec, when the work needs one

Work large enough that the packet would not hold it gets a spec first. Settle it with the user in conversation, then write one file to `context/specs/YYYY-MM-DD-topic.md` relative to the repository root, using today's date and a short kebab-case topic. Create the directory when needed. Never overwrite an existing spec; add a numeric suffix instead.

```markdown
# <topic>

## Goal
What outcome this produces, and why it is wanted.

## Scope
In scope, as a short list. Out of scope, when a reader would otherwise assume it.

## Approach
The chosen approach in a few sentences. Name a rejected alternative only when the choice is genuinely contested.

## Files
Each file to change, with exact paths and line ranges where known, and one line on what changes in it.

## Acceptance criteria
Observable conditions that make this done. Testable statements, not restatements of the approach.

## Checks
The specific commands to run, taken from the repository's own tooling.

## Open questions
Anything that could change the approach, and who or what resolves it. Omit the section when there are none.
```

Keep the spec as short as the work allows. Prefer exact paths, symbols, and commands over prose. Give the user the path and let them edit it before `worker` starts. Small, obvious work skips this step entirely.

Work too large for one `worker` pass gets phases: use the `breakdown` skill to append a `## Phases` section to the spec, then dispatch one wave at a time, reading each phase's report before starting the next.

## Write the packet

Each agent starts with no access to this conversation, so every packet is self-contained. Quote the evidence rather than telling the agent to go find it. A packet that says "continue the work" or "fix the bug we discussed" will fail.

Mutating agents (`worker`, and any other agent that will write) require all six fields:

- **Goal** — the outcome this agent must produce, and why.
- **Use** — non-inheritable context: exact paths, line ranges, quotes, constraints, and evidence this agent needs. Do not assume prior conversation.
- **Own** — the files or surfaces this agent may change.
- **Do not** — hard exclusions: files, behaviors, and side effects that are out of bounds.
- **Return** — what the report must contain so the main thread can verify and continue.
- **Stop if** — conditions that halt the agent and return early instead of guessing.

Scout, reviewer, and advisor need **Goal**, **Use**, **Return**, and **Stop if**. Include **Own** and **Do not** when they write.

`worker` and `reviewer` can load skills themselves and know when their own apply. Name a skill in the packet only when you want it used for a reason the agent cannot see from the task, such as the user asking for test-first on a change that would not otherwise get it.

## Hold the result

Read each report before acting on it. Check the claims that matter against the files, and say so plainly when a report is wrong or thin rather than passing it along. Relay what the user needs: what changed, which files, which checks ran and their results, and what is unresolved. Agent reports are not shown to the user.

When a spec exists, point the user at its path. Stop and ask before starting a chain that would cost far more than the task warrants.
