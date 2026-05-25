# vaibes

A small library of reusable agent prompts and task-specific skills.

## Skills

| Skill | Use For | Not For |
| --- | --- | --- |
| [`commit`](./skills/commit/SKILL.md) | Creating a local git commit with an intentional Conventional Commits-style message, including staging only the intended files. | Pushing, opening PRs, or explaining git without committing. |
| [`deslop`](./skills/deslop/SKILL.md) | Removing AI-looking slop from the current branch diff while preserving behavior and keeping cleanup branch-local. | Broad refactors, redesigns, formatting-only passes, or general code review. |
| [`implement`](./skills/implement/SKILL.md) | Implementing one ready-for-agent GitHub issue from `ISSUE_NUMBER`, `ISSUE_URL`, and `BRANCH`, using `gh`, TDD where appropriate, checks, commit, and issue update/close. | Local `.scratch` issues, backlog triage, PR creation, or multi-issue work. |
| [`implement-locally`](./skills/implement-locally/SKILL.md) | Implementing one ready-for-agent local markdown issue from `.scratch/<feature>/issues/`, `ISSUE_FILE`, and `BRANCH`, including parent PRD context when present. | GitHub issues, backlog triage, PR creation, or multi-issue work. |
| [`pr`](./skills/pr/SKILL.md) | Opening or updating a pull request with a clear title and compact reviewer-focused body. | Making commits, changing code, or replacing a detailed release note. |

## Curated Skills

1. [Matt Pocock](https://github.com/mattpocock/skills)

```bash
npx skills@latest add mattpocock/skills
```

**Personal Picks:**

- [setup-matt-pocock-skills](https://github.com/mattpocock/skills/tree/main/skills/engineering/setup-matt-pocock-skills)
- [grill-with-docs](https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs)
- [improve-codebase-architecture](https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture)
- [to-prd](https://github.com/mattpocock/skills/tree/main/skills/engineering/to-prd)
- [to-issue](https://github.com/mattpocock/skills/tree/main/skills/engineering/to-issues)
- [tdd](https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd)
- [prototype](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype)
- [handoff](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff)

2. [Jakub Krehel Better UI](https://github.com/jakubkrehel/make-interfaces-feel-better)

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
