# vaibes

My personal library of agent skills.

## Install

```bash
npx skills@latest add ronalson/vaibes
```

> See https://github.com/vercel-labs/skills for more options.

### Claude Code agents and the `scout` skill

`npx skills` installs only folders under `skills/`. The Claude Code pieces that `delegate` uses live in `claude/` and need a manual step:

| File | What it is |
| --- | --- |
| `claude/agents/reviewer.md` | Read-only reviewer agent, `effort: high`, no model pin |
| `claude/agents/advisor.md` | Read-only advisor agent, `model: opus`, `effort: xhigh` |
| `claude/skills/scout/SKILL.md` | Optional. Forks the built-in Explore agent on Haiku at medium effort |

Link them from a local clone so `git pull` keeps them current:

```bash
VAIBES=/path/to/vaibes   # your local clone of ronalson/vaibes
mkdir -p ~/.claude/agents ~/.claude/skills
ln -s "$VAIBES/claude/agents/reviewer.md" ~/.claude/agents/reviewer.md
ln -s "$VAIBES/claude/agents/advisor.md"  ~/.claude/agents/advisor.md
ln -s "$VAIBES/claude/skills/scout"       ~/.claude/skills/scout   # optional
```

Notes:

- Restart Claude Code if `~/.claude/agents/` did not exist when the session started. After that, agent edits reload without a restart.
- A project's `.claude/agents/reviewer.md` or `advisor.md` takes priority over these user-level files.
- They are Claude Code only. Codex and other harnesses never see `claude/`. `delegate` there pastes the contracts from `skills/delegate/references/` instead, and Codex uses `ask-astra` as the advisor.
- `haiku` and `opus` resolve to older models on Bedrock, Google Cloud, and Claude Platform on AWS. On those providers, pin full IDs such as `claude-haiku-5-5`.
- If you still have the `agent@ronalson` plugin from cc-subagents, its agents are `agent:reviewer` and so on. They don't clash with these, but uninstall the plugin once you've switched.

## Skills

| Skill | Use For | Not For |
| --- | --- | --- |
| [`ask-astra`](./skills/ask-astra/SKILL.md) | Letting Sol consult a read-only Astra advisor for difficult decisions, architectural trade-offs, or an independent review. | Routine implementation, searches, or verification. |
| [`bro`](./skills/bro/SKILL.md) | Restating the previous message in plain, concise language. | Providing new analysis, instructions, or technical detail. |
| [`breakdown`](./skills/breakdown/SKILL.md) | Splitting a settled plan into vertical, reviewable phases with waves and review gates. | Breaking down a plan the user has not agreed to, or horizontal layering. |
| [`codebase-design`](./skills/codebase-design/SKILL.md) | Designing deep modules, improving interfaces, finding seams, and making code easier to test or navigate. | General implementation work that does not involve module or interface design. |
| [`deslop`](./skills/deslop/SKILL.md) | Reviewing a branch diff against a requested or discovered base to remove AI-generated code slop while preserving behavior. | Broad refactors, intentional behavior changes, or solving unclear bugs. |
| [`delegate`](./skills/delegate/SKILL.md) | Orchestrating scout/worker/reviewer/advisor with self-contained packets instead of implementing on the main thread. | Doing the implementation yourself, or delegating without a settled plan. |
| [`file-pr`](./skills/file-pr/SKILL.md) | Opening a pull request or updating an existing one within the request, with a clear title and concise body. | Making commits, pushes, or implementation changes. |
| [`grill-me`](./skills/grill-me/SKILL.md) | Relentlessly stress-testing a plan, decision, or idea through structured questions. | Implementation or lightweight brainstorming that does not need a decision audit. |
| [`handoff`](./skills/handoff/SKILL.md) | Compacting the current conversation into a redacted handoff document in `context/handoff/` for another agent to pick up. | Permanent project documentation, PRDs, ADRs, or issue breakdowns. |
| [`html-doc`](./skills/html-doc/SKILL.md) | Creating a single-file HTML document for specs, findings, reports, comparisons, and visualizations. Its CDN styling requires network access. | Plain-text answers or documents that must use another file format. |
| [`prototype`](./skills/prototype/SKILL.md) | Building a throwaway prototype to explore a state model, business logic question, or UI direction before committing to it. | Production implementation, polished UI delivery, persistent data flows, or long-lived experiments. |
| [`show-me`](./skills/show-me/SKILL.md) | Explaining the current topic with concise diagrams, code-shape sketches, and focused HTML artifacts. | Long prose lessons or visuals that do not answer the current question. |
| [`teach-codebase`](./skills/teach-codebase/SKILL.md) | Explaining a codebase, subsystem, runtime path, or symbol so someone can change it safely. | Implementing changes or giving ungrounded architectural advice. |
| [`technical-writing`](./skills/technical-writing/SKILL.md) | Writing or reviewing clear technical docs, RFCs, READMEs, PR descriptions, and commit messages. | Product UI copy or documentation outside the project's real terminology and behavior. |
| [`tdd`](./skills/tdd/SKILL.md) | Building features or fixing bugs with a red-green-refactor loop and behavior-focused tests. | Bulk test generation, implementation-detail tests, or changes where tests are intentionally out of scope. |
| [`type-spec`](./skills/type-spec/SKILL.md) | Creating implementation-ready architecture handoffs with typed contracts and call stacks. | Implementing the design or inventing requirements without enough context. |
| [`unslop`](./skills/unslop/SKILL.md) | Editing writing to remove AI tells and give it a specific, human voice. | Changing the underlying meaning, facts, or intended tone. |

## Attribution

The skills below began as upstream work and are now locally maintained adaptations. The recorded commits are the last source versions captured before this repository stopped syncing them. The upstream license files remain in `vendor/`.

| Local skill | Upstream source | Original name | Last recorded commit |
| --- | --- | --- | --- |
| `tdd` | [Matt Pocock](https://github.com/mattpocock/skills/tree/main/skills/engineering/tdd) | `tdd` | `6654f6b` |
| `codebase-design` | [Matt Pocock](https://github.com/mattpocock/skills/tree/main/skills/engineering/codebase-design) | `codebase-design` | `6654f6b` |
| `prototype` | [Matt Pocock](https://github.com/mattpocock/skills/tree/main/skills/engineering/prototype) | `prototype` | `6654f6b` |
| `grill-me` | [Matt Pocock](https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md) | `grilling` | `6654f6b` |
| `type-spec` | [Dillon Mulroy](https://github.com/dmmulroy/skills/blob/main/tech-spec/SKILL.md) | `tech-spec` | `8603380` |
| `show-me` | [HumanLayer](https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md) | `show-me` | `6ab9013` |
| `bro` | [cursor plugins](https://github.com/cursor/plugins/blob/main/pstack/skills/bro/SKILL.md) | `bro` | `7314f72` |
| `unslop` | [cursor plugins](https://github.com/cursor/plugins/blob/main/pstack/skills/unslop/SKILL.md) | `unslop` | `7314f72` |
| `technical-writing` | [cursor plugins](https://github.com/cursor/plugins/blob/main/pstack/skills/technical-writing/SKILL.md) | `technical-writing` | `7314f72` |
| `deslop` | [cursor plugins](https://github.com/cursor/plugins/blob/main/cursor-team-kit/skills/deslop/SKILL.md) | `deslop` | `7314f72` |
