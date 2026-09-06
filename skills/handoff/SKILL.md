---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
disable-model-invocation: true
---

Write a handoff markdown document summarising the current conversation so a fresh agent can continue the work. By default, save it in `<repo-root>/context/handoff/`, creating that directory when it does not exist. Use a descriptive, non-overwriting filename such as `YYYY-MM-DD-topic.md`; add a suffix when that name already exists.

Include the objective, constraints, completed work, remaining work, relevant references, and verification status.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
