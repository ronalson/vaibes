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
| [`codebase-design`](./skills/codebase-design/SKILL.md) | Designing deep modules, improving interfaces, finding seams, and making code easier to test or navigate. | General implementation work that does not involve module or interface design. |
| [`file-pr`](./skills/file-pr/SKILL.md) | Opening or updating a pull request with a clear title and concise body. | Making commits or changing the implementation. |
| [`grill-me`](./skills/grill-me/SKILL.md) | Relentlessly stress-testing a plan, decision, or idea through structured questions. | Implementation or lightweight brainstorming that does not need a decision audit. |
| [`handoff`](./skills/handoff/SKILL.md) | Compacting the current conversation into a handoff document for another agent to pick up. | Permanent project documentation, PRDs, ADRs, or issue breakdowns. |
| [`html-doc`](./skills/html-doc/SKILL.md) | Communicating specs, findings, reports, comparisons, and visualizations as a self-contained HTML document. | Plain-text answers or documents that must use another file format. |
| [`prototype`](./skills/prototype/SKILL.md) | Building a throwaway prototype to explore a state model, business logic question, or UI direction before committing to it. | Production implementation, polished UI delivery, persistent data flows, or long-lived experiments. |
| [`tdd`](./skills/tdd/SKILL.md) | Building features or fixing bugs with a red-green-refactor loop and behavior-focused tests. | Bulk test generation, implementation-detail tests, or changes where tests are intentionally out of scope. |

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

- [tdd](https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd)
- [codebase-design](https://github.com/mattpocock/skills/tree/main/skills/engineering/codebase-design)
- [prototype](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype)

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
