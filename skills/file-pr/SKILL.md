---
name: file-pr
description: File a concise pull request. Use when the user asks to file, open, or create a PR.
---

Create or update a pull request for the current branch using a clear title and a concise body.

Before filing, check whether the current branch already has a PR. If one exists, do not create a duplicate; update it only within the user's request. Resolve the base branch from repository evidence when possible, such as an existing PR, branch configuration, or the repository's default branch, then review the diff and confirm it matches the requested change.

Creating or updating a PR does not authorize commits or pushes. Obtain separate authorization for either when needed.

**Title**
- Prefer a short imperative summary, <= 72 chars, with no trailing period.
- If the repo uses Conventional Commits, reuse that style for the PR title when it still reads naturally.
- Keep the title aligned with the actual diff, not the branch name.

**Body**
- Keep the body brief and reviewer-oriented.
- Mention affected user behavior, important implementation decisions, and anything a reviewer should inspect closely.
- Include `Closes #123` or equivalent only when the linked issue is known.
- Report verification that ran, did not run, is unavailable, or is unknown accurately. Ask the user only when a material unresolved choice prevents filing or updating the PR.
