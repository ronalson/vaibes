---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up.
disable-model-invocation: true
---

Write a handoff markdown document summarising the current conversation so a fresh agent can continue the work. By default, save it in `<repo-root>/context/handoff/`, creating that directory when it does not exist. Use a descriptive, non-overwriting filename such as `YYYY-MM-DD-topic.md`; add a suffix when that name already exists.

Include these sections:

- **Objective** - the outcome the next agent should achieve
- **Preserve / constraints** - what must not change and any hard limits
- **Completed work** - what is already done
- **Remaining work** - what is left
- **Accept when** - how the next agent knows remaining work is done
- **Stop and ask if** - conditions that should pause work and return to the user
- **References** - paths or URLs only; do not duplicate content already in other artifacts (PRDs, plans, ADRs, issues, commits, diffs)
- **Verification status** - what was last checked, and whether that check ran after the final mutation

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
