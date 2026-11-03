---
name: handoff
description: Hand planned work to another agent or a fresh session as a short implementation spec in context/specs/, with a required Validation section that says how the work is proven. Use when work is too large for a single packet or prompt but does not need a typed architecture spec (type-spec).
---

# Handoff

Write one short spec that another agent can implement and prove without this conversation. Design only: do not implement.

## Inputs

The settled plan from the conversation, plus what you read in the repo. If the goal or scope is still open, settle it with the user first (`grill-me` helps). Answer questions the codebase can answer by reading it.

## Write the spec

1. Start from [references/spec-template.md](references/spec-template.md). Read it before writing; keep its sections and order.
2. Write the **Validation** section as [references/validation.md](references/validation.md) defines it. Read that file before writing Validation. Look for `.claude/skills/verify-<app>/` in the target repo for feature-map IDs, and take commands from the repo's own files. If the repo has no `verify-<app>` skill, say so in the spec and tell the user that `/create-verification-skill` can add one.
3. Keep the spec as short as the work allows. Prefer exact paths, symbols, and commands over prose.
4. Save to `context/specs/YYYY-MM-DD-topic.md` from the repository root, using today's date and a short kebab-case topic. Create the directory when needed. Never overwrite an existing file; add a numeric suffix instead (`-2`, `-3`).

## Done means

- The spec file is saved and you gave the user its path, so they can edit it before work starts.
- Its Validation section passes every item under "Complete or incomplete" in [references/validation.md](references/validation.md).

A spec whose Validation is incomplete is not done and must not go to `breakdown`. Tell the user which items fail.

## Stop and ask when

- The repo has no command that would prove the work. Do not invent one.
- No check can fail before the change, so the fail-first item can't be met.
- An open question would change the approach.
