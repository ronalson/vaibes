# vaibes

A small library of reusable agent context: static rules, prompt templates, and task-specific skills.

## Structure

- [`rules/`](./rules) contains always-on repo or agent guidance.
- [`prompts/`](./prompts) contains lean prompt templates for repeatable workflows.
- [`skills/`](./skills) contains focused task guides the agent should read before doing specific kinds of work.

## Rules

Rules are static instructions. They should stay short and contain only durable constraints or conventions.

- [`rules/AGENTS.md`](./rules/AGENTS.md): project rules for planning, git usage, and pull request conventions.
- [`rules/CLAUDE.md`](./rules/CLAUDE.md): points Claude-style tooling at `AGENTS.md` as the canonical rules file.

## Prompts

Prompts are lightweight Markdown templates. Keep them explicit about input, task, and output.

- [`prompts/better-rules.md`](./prompts/better-rules.md): generate or tighten an `AGENTS.md` file using only project-specific context.
- [`prompts/deslop.md`](./prompts/deslop.md): clean AI-style slop from a branch diff without broad refactoring.
- [`prompts/lets-discuss.md`](./prompts/lets-discuss.md): interview the user about a plan, then rewrite it as a stronger spec.
- [`prompts/prototype.md`](./prompts/prototype.md): scope and build a narrow prototype to validate an idea quickly.

Design goals for prompts in this repo:
- Stay lean.
- Prefer clear stop conditions.
- Prefer specific deliverables over open-ended exploration.
- Avoid runtime-specific wording unless the prompt is intentionally tied to one agent.

## Skills

Skills are small operating guides for specific tasks. Each skill lives in its own folder with a required `SKILL.md`.

- [`skills/commit/SKILL.md`](./skills/commit/SKILL.md): create a concise Conventional Commits-style git commit and stage only the intended files.
- [`skills/github/SKILL.md`](./skills/github/SKILL.md): use the `gh` CLI for GitHub issues, pull requests, workflow runs, and API queries.
- [`skills/pr/SKILL.md`](./skills/pr/SKILL.md): open or update a PR with a clear title and a compact reviewer-focused body.

Skill design goals in this repo:
- Be short enough to load quickly.
- Tell the agent what good output looks like.
- Add only task-specific guidance, not generic engineering advice.
- Prefer a simple step-by-step workflow when the task is easy to get subtly wrong.

## Authoring Notes

When adding new files here:
- Put durable conventions in `rules/`.
- Put reusable one-shot workflows in `prompts/`.
- Put richer task guidance in `skills/<name>/SKILL.md`.
- Keep everything concise and biased toward practical execution.
