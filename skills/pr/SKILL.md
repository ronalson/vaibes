---
name: pr
description: "Read this skill before opening or updating a pull request"
---

Create or update a pull request for the current branch using a clear title and a concise review-focused body.

## Title

- Prefer a short imperative summary, <= 72 chars, with no trailing period.
- If the repo uses Conventional Commits, reuse that style for the PR title when it still reads naturally.
- Keep the title aligned with the actual diff, not the branch name.

## Body

Use this structure:

```md
## Summary

- What changed
- Why it changed

## Testing

- How the change was verified

## Notes

- Risks, migrations, follow-ups, or rollout details
```

## Notes

- Keep the body brief and reviewer-oriented.
- Mention user-visible behavior, important implementation decisions, and anything a reviewer should inspect closely.
- Include `Closes #123` or equivalent only when the linked issue is known.
- Include screenshots only for visual changes and only if they are available.
- Do NOT mention AI tools, generated code, or sign-offs.
- If the change is too large or mixed, tell the user before opening the PR.
- If the intended base branch, issue link, or testing status is unclear, ask the user instead of guessing.

## Steps

1. Review the current branch, commits, and diff against the target base branch.
2. Infer the main user-facing change and any important reviewer context.
3. Write a clear PR title that matches the diff.
4. Write a short PR body using `Summary`, `Testing`, and `Notes`, omitting empty sections when appropriate.
5. Open or update the PR with that title and body.
