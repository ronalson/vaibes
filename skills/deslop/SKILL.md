---
name: deslop
description: Remove AI-generated code slop and clean up code style
---

# Remove AI code slop

Check the requested branch diff and remove AI-generated slop introduced in the branch. Use a user-specified base when provided; otherwise discover the actual comparison base from repository evidence. Do not assume the base is `main`.

## Focus Areas

- Extra comments that are unnecessary or inconsistent with local style
- Defensive checks or try/catch blocks that are abnormal for trusted code paths
- Casts to `any` used only to bypass type issues
- Deeply nested code that should be simplified with early returns
- Other patterns inconsistent with the file and surrounding codebase

## Guardrails

- Keep behavior unchanged. If cleanup reveals a behavior bug, report it separately; fix it only when the request already includes that fix.
- Prefer minimal, focused edits over broad rewrites.
- Keep the final summary concise (1-3 sentences).
