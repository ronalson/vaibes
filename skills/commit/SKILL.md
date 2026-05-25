---
name: commit
description: Create a local git commit with an intentional Conventional Commits-style message. Use whenever the user asks to commit changes, make a git commit, save current work in git, commit specific files, or when another workflow reaches its commit step. This skill should guide staging, message selection, and commit execution; do not use it for pushing, opening PRs, or merely explaining git unless a commit will actually be made.
---

Create a local git commit for the intended changes using a concise Conventional Commits-style subject.

Stay careful about scope: the user is trusting you to commit exactly the right changes, not every uncommitted file that happens to exist.

## Format

`<type>(<scope>): <summary>`

- `type` REQUIRED. Use `feat` for new features, `fix` for bug fixes. Other common types: `docs`, `refactor`, `chore`, `test`, `perf`.
- `scope` OPTIONAL. Short noun in parentheses for the affected area (e.g., `api`, `parser`, `ui`).
- `summary` REQUIRED. Short, imperative, <= 72 chars, no trailing period.

## Notes

- Body is OPTIONAL. If needed, add a blank line after the subject and write short paragraphs.
- Do NOT include breaking-change markers or footers.
- Do NOT add sign-offs (no `Signed-off-by`).
- Do NOT include AI author references like `Co-authored-by` or `Made-with`.
- Only commit; do NOT push.
- Do NOT amend an existing commit unless the user explicitly asks.
- If there are no changes to commit, say so and stop.
- If it is unclear whether a file should be included, ask the user which files to commit.
- Treat any caller-provided arguments as additional commit guidance. Common patterns:
  - Freeform instructions should influence scope, summary, and body.
  - File paths or globs should limit which files to commit. If files are specified, only stage/commit those unless the user explicitly asks otherwise.
  - If arguments combine files and instructions, honor both.

## Steps

1. Infer from the prompt if the user provided specific file paths/globs and/or additional instructions.
2. Review `git status` and the relevant `git diff` to understand the current changes. Limit the review to argument-specified files when provided.
3. If useful, run `git log -n 50 --pretty=format:%s` to match common local commit types/scopes.
4. Decide the intended file set. If unrelated or ambiguous files are present, ask the user before staging them.
5. Stage only the intended files. If the user specified files, stage only those files unless they explicitly asked otherwise.
6. Review `git diff --staged` before committing so the subject matches the staged patch.
7. Run `git commit -m "<subject>"` (and `-m "<body>"` if needed).
8. Report the commit hash and subject. Mention any uncommitted files left behind.
