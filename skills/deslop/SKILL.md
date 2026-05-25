---
name: deslop
description: Remove AI-looking slop from the current branch diff while preserving behavior. Use when the user asks to deslop, clean AI-generated code, make a branch feel hand-written, remove overengineered or unnatural changes, review a diff for AI artifacts, or clean up comments/defensive code/type escapes introduced by this branch. This skill is for small branch-local cleanup, not broad refactors, redesigns, formatting-only passes, or general code review.
---

Clean the current branch diff so the changed code feels native to the repository.

Check the diff against branch `$0` if provided; otherwise use the repo's default base branch. Focus only on changes introduced by this branch.

## What To Remove

- Comments that explain obvious code, narrate edits, or do not match the file's normal commenting style.
- Defensive checks, fallback branches, try/catch blocks, or validation layers that are abnormal for that area, especially on trusted or already-validated code paths.
- Type escapes such as `any`, broad casts, non-null assertions, or loose object shapes used to avoid solving a type issue.
- Overly generic helpers, wrappers, configuration knobs, or abstractions introduced for a one-off change.
- Naming, branching, or formatting choices that stand out from nearby code and appear only in the branch diff.

## Boundaries

- Preserve intended behavior unless a branch-local change is clearly unnecessary.
- Prefer the smallest edit that makes the diff feel native to the repo.
- Match the surrounding file's style instead of imposing a new one.
- Do not rewrite stable code outside the branch diff unless it is required to remove branch-local slop.
- Do not broaden this into a feature refactor, architecture cleanup, or formatting-only pass.
- If a suspicious change may be intentional, leave it in place and mention it rather than guessing.

## Steps

1. Identify the comparison base from `$0` or the repo's default base branch.
2. Review `git diff` against that base and list the changed files mentally by risk.
3. Inspect nearby code before editing so cleanup decisions follow local conventions.
4. Remove or simplify only branch-local AI-looking artifacts.
5. Recheck the diff to confirm behavior was preserved and no unrelated cleanup slipped in.

At the end, reply with only a 1-3 sentence summary of what you changed.
