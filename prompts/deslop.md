---
description: Remove AI-style slop from this branch
---

Check the diff against `$1` if provided; otherwise use the repo's default base branch. Remove AI-generated slop introduced in this branch.

This includes:
- Extra comments that a human wouldn't add or is inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to `any` used to get around type issues
- Any other style that is inconsistent with the file

Guidelines:
- Preserve behavior unless a change is clearly unnecessary
- Prefer the smallest edits that make the code feel native to the repo
- Do not broaden this into a full refactor

At the end, reply with only a 1-3 sentence summary of what you changed.
