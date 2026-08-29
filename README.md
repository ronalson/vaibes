# vaibes

My personal library of agent skills.

## Install

```bash
npx skills@latest add ronalson/vaibes
```

> See https://github.com/vercel-labs/skills for more options.

## Skills

| Skill | Use For | Not For |
| --- | --- | --- |
| [`bro`](./skills/bro/SKILL.md) | Restating the previous message in plain, concise language. | Providing new analysis, instructions, or technical detail. |
| [`codebase-design`](./skills/codebase-design/SKILL.md) | Designing deep modules, improving interfaces, finding seams, and making code easier to test or navigate. | General implementation work that does not involve module or interface design. |
| [`deslop`](./skills/deslop/SKILL.md) | Reviewing a branch diff to remove AI-generated code slop while preserving behavior. | Broad refactors, intentional behavior changes, or solving unclear bugs. |
| [`file-pr`](./skills/file-pr/SKILL.md) | Opening or updating a pull request with a clear title and concise body. | Making commits or changing the implementation. |
| [`grill-me`](./skills/grill-me/SKILL.md) | Relentlessly stress-testing a plan, decision, or idea through structured questions. | Implementation or lightweight brainstorming that does not need a decision audit. |
| [`handoff`](./skills/handoff/SKILL.md) | Compacting the current conversation into a handoff document for another agent to pick up. | Permanent project documentation, PRDs, ADRs, or issue breakdowns. |
| [`html-doc`](./skills/html-doc/SKILL.md) | Communicating specs, findings, reports, comparisons, and visualizations as a self-contained HTML document. | Plain-text answers or documents that must use another file format. |
| [`prototype`](./skills/prototype/SKILL.md) | Building a throwaway prototype to explore a state model, business logic question, or UI direction before committing to it. | Production implementation, polished UI delivery, persistent data flows, or long-lived experiments. |
| [`technical-writting`](./skills/technical-writting/SKILL.md) | Writing or reviewing clear technical docs, RFCs, READMEs, PR descriptions, and commit messages. | Product UI copy or documentation outside the project's real terminology and behavior. |
| [`teach-codebase`](./skills/teach-codebase/SKILL.md) | Building a working mental model of a codebase, subsystem, feature, flow, or symbol before changing it. | Implementing changes or producing a shallow file-by-file walkthrough. |
| [`tdd`](./skills/tdd/SKILL.md) | Building features or fixing bugs with a red-green-refactor loop and behavior-focused tests. | Bulk test generation, implementation-detail tests, or changes where tests are intentionally out of scope. |
| [`type-spec`](./skills/type-spec/SKILL.md) | Creating implementation-ready architecture handoffs with typed contracts and call stacks. | Implementing the design or inventing requirements without enough context. |
| [`unslop`](./skills/unslop/SKILL.md) | Editing writing to remove AI tells and give it a specific, human voice. | Changing the underlying meaning, facts, or intended tone. |

## Curated Skills

### [Matt Pocock](https://github.com/mattpocock/skills)

- [tdd](https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd) (synced)
- [codebase-design](https://github.com/mattpocock/skills/tree/main/skills/engineering/codebase-design) (synced)
- [prototype](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype) (synced)
- [grilling](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md) renamed to `grill-me`

### [Dillon Mulroy](https://github.com/dmmulroy/skills)

- [tech-spec](https://github.com/dmmulroy/skills/blob/main/tech-spec/SKILL.md) renamed to `type-spec`

### [cursor plugins](https://github.com/cursor/plugins/tree/main/pstack)

- **pstack**
  - [technical-writting](https://github.com/cursor/plugins/blob/main/pstack/skills/technical-writing/SKILL.md)
  - [unslop](https://github.com/cursor/plugins/blob/main/pstack/skills/unslop/SKILL.md)
  - [bro](https://github.com/cursor/plugins/blob/main/pstack/skills/bro/SKILL.md)
- **cursor team kit**
  - [deslop](https://github.com/cursor/plugins/blob/main/cursor-team-kit/skills/deslop/SKILL.md)

#### Syncing skills

Run the script to sync the selected skills from Matt Pocock: `tdd`, `codebase-design`, and `prototype`.

```bash
./vendor/sync-mattpocock-skills.sh
```
