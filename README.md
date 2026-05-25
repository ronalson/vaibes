# vaibes

A small library of reusable agent prompts and task-specific skills.

## Install

```bash
npx skills@latest add ronalson/vaibes
```

> See https://github.com/vercel-labs/skills for more options.

## Skills

| Skill | Use For | Not For |
| --- | --- | --- |
| [`commit`](./skills/commit/SKILL.md) | Creating a local git commit with an intentional Conventional Commits-style message, including staging only the intended files. | Pushing, opening PRs, or explaining git without committing. |
| [`deslop`](./skills/deslop/SKILL.md) | Removing AI-looking slop from the current branch diff while preserving behavior and keeping cleanup branch-local. | Broad refactors, redesigns, formatting-only passes, or general code review. |
| [`grill-with-docs`](./skills/grill-with-docs/SKILL.md) | Stress-testing a plan against the repo's domain model, sharpening terminology, and updating `CONTEXT.md` or ADRs as decisions settle. | Quick implementation, lightweight brainstorming, or plans that do not need domain-doc alignment. |
| [`handoff`](./skills/handoff/SKILL.md) | Compacting the current conversation into a handoff document for another agent to pick up. | Permanent project documentation, PRDs, ADRs, or issue breakdowns. |
| [`implement`](./skills/implement/SKILL.md) | Implementing one ready-for-agent GitHub issue from `ISSUE_NUMBER`, `ISSUE_URL`, and `BRANCH`, using `gh`, TDD where appropriate, checks, commit, and issue update/close. | Local `.scratch` issues, backlog triage, PR creation, or multi-issue work. |
| [`implement-locally`](./skills/implement-locally/SKILL.md) | Implementing one ready-for-agent local markdown issue from `.scratch/<feature>/issues/`, `ISSUE_FILE`, and `BRANCH`, including parent PRD context when present. | GitHub issues, backlog triage, PR creation, or multi-issue work. |
| [`improve-codebase-architecture`](./skills/improve-codebase-architecture/SKILL.md) | Finding architecture deepening opportunities informed by `CONTEXT.md` and ADRs. | Formatting cleanup, isolated bug fixes, or feature implementation without architectural analysis. |
| [`pr`](./skills/pr/SKILL.md) | Opening or updating a pull request with a clear title and compact reviewer-focused body. | Making commits, changing code, or replacing a detailed release note. |
| [`prototype`](./skills/prototype/SKILL.md) | Building a throwaway prototype to explore a state model, business logic question, or UI direction before committing to it. | Production implementation, polished UI delivery, persistent data flows, or long-lived experiments. |
| [`setup-matt-pocock-skills`](./skills/setup-matt-pocock-skills/SKILL.md) | Setting up repo-local agent skill context for issue tracker conventions, triage labels, and domain docs. | General project bootstrapping or running the other skills after setup already exists. |
| [`tdd`](./skills/tdd/SKILL.md) | Building features or fixing bugs with a red-green-refactor loop and behavior-focused tests. | Bulk test generation, implementation-detail tests, or changes where tests are intentionally out of scope. |
| [`to-issues`](./skills/to-issues/SKILL.md) | Breaking a plan, spec, or PRD into independently grabbable vertical-slice issues. | Writing the original PRD, casual todo lists, or implementing the issues. |
| [`to-prd`](./skills/to-prd/SKILL.md) | Turning current conversation context into a PRD and publishing it to the configured issue tracker. | Open-ended interviewing, breaking the PRD into tickets, or implementation. |

## Curated Skills

1. [Matt Pocock](https://github.com/mattpocock/skills)

```bash
npx skills@latest add mattpocock/skills
```

To sync only the personal picks into this repo and review upstream updates:

```bash
./vendor/sync-mattpocock-skills.sh
git diff -- skills vendor
```

The sync script clones the upstream repo into a temporary directory by default. To reuse
a local checkout instead, set `MATTPOCOCK_SKILLS_SOURCE=/path/to/mattpocock-skills`.

**Personal Picks:**

- [setup-matt-pocock-skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/setup-matt-pocock-skills)
- [grill-with-docs](https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs)
- [improve-codebase-architecture](https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture)
- [to-prd](https://github.com/mattpocock/skills/tree/main/skills/engineering/to-prd)
- [to-issues](https://github.com/mattpocock/skills/tree/main/skills/engineering/to-issues)
- [tdd](https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd)
- [prototype](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype)
- [handoff](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff)

2. [Jakub Krehel - Make interfaces Feel Better](https://github.com/jakubkrehel/make-interfaces-feel-better)

Site: https://jakub.kr/writing/details-that-make-interfaces-feel-better

```bash
npx skills add jakubkrehel/make-interfaces-feel-better
```

3. [Emil Kowalski Design Engineer](https://github.com/emilkowalski/skill)

Site: https://emilkowal.ski/skill

```bash
npx skills add emilkowalski/skill
```

4. [Google's Modern Web Guidance](https://github.com/GoogleChrome/modern-web-guidance-src)

```bash
npx modern-web-guidance@latest install
```
