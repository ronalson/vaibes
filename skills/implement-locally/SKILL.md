---
name: implement-locally
description: Implement a single ready-for-agent local markdown issue end to end. Use when the task points at an issue file under `.scratch/<feature>/issues/`, provides `ISSUE_FILE` and `BRANCH`, or asks to run the implementation phase for a repo configured by `setup-matt-pocock-skills` with the local markdown issue tracker. This skill should read the local issue and parent `.scratch/<feature>/PRD.md` when present, work only on the specified branch and issue, use TDD when applicable, run checks, commit the result, and update the local issue state as instructed. Do not use for GitHub issues, broad backlog triage, PR creation, or multi-issue work.
---

# TASK

Fix issue {{ISSUE_FILE}}.

Pull in the issue using `.scratch/{folder}`. If it has a parent PRD, pull that in too.

Only work on the issue specified.

Work on branch {{BRANCH}}. Make commits, run tests, and close the issue when done.

# CONTEXT

Here are the last 10 commits:

<recent-commits>

!`git log -n 10 --format="%H%n%ad%n%B---" --date=short`

</recent-commits>

# EXPLORATION

Explore the repo and fill your context window with relevant information that will allow you to complete the task.

Pay extra attention to test files that touch the relevant parts of the code.

# EXECUTION

If applicable, use RGR to complete the task.

Use skill `/tdd`

1. RED: write one test
2. GREEN: write the implementation to pass that test
3. REPEAT until done
4. REFACTOR the code

# FEEDBACK LOOPS

Before committing, run `npm run typecheck` and `npm run test` to ensure the tests pass.

# USER REVIEW (OPTIONAL)

If applicable, stop here before commiting.

1. Stage the files you intend to commit.
2. Pause and ask the driver to review the changes.

# COMMIT

Make a git commit. The commit message must:

1. Include task completed + PRD reference
2. Key decisions made
3. Files changed
4. Blockers or notes for next iteration

Keep it concise.

# THE ISSUE

If the task is not complete, leave a comment on the GitHub issue with what was done.

CRITICAL: Do not close the issue - this will be done later.

Once complete, output <promise>COMPLETE</promise>.

# FINAL RULES

ONLY WORK ON A SINGLE TASK.
