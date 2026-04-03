---
description: Generate or improve the AGENTS.md file
---

Generate an AGENTS.md file.

This file provides STATIC, always-on context for the project. It is not a task guide.

Requirements:
- Keep the file short (≤150 lines)
- Include ONLY project-specific information
- Assume the agent already knows common tools and best practices

Include:
1. A one-sentence project description
2. Non-standard commands (wrap in backticks)
3. Critical conventions or patterns the agent must follow
4. Workflow constraints that prevent mistakes
5. Pointers to canonical files (link instead of copying)

Exclude:
- Generic advice (“write clean code”, “follow best practices”)
- Full style guides
- Rare edge cases
- Task-specific instructions
- Duplicated documentation

If unsure whether something belongs here, exclude it.

Example template:

```
# Project Abc

Monorepo of React + TypeScript packages managed by pnpm workspaces and Turborepo.

## Repo layout

- `packages/` — each subdirectory is a publishable package; the canonical name is the `name` field in its `package.json`
- `.github/workflows/` — CI definitions (lint → test → build)
- `turbo.json` — pipeline config; check here before adding or reordering tasks

## Commands

```bash
# Navigate to a package
pnpm dlx turbo run where <package_name>

# Scaffold a new package
pnpm create vite@latest packages/<dir> -- --template react-ts

# Install a dependency scoped to one package
pnpm install <dep> --filter <package_name>

# Run tasks
pnpm turbo run test --filter <package_name>
pnpm turbo run lint --filter <package_name>

# Run a single test by name (from package root)
pnpm vitest run -t "<test name>"
```

## Conventions

- Always resolve package names from `package.json` `name`, never from directory names.
- Run `pnpm lint` and `pnpm test` before every commit. CI runs the same checks; broken commits block merges.
- When you change code, add or update tests to cover it — even if not requested.
- After moving files or changing imports, re-run lint to catch stale references.

## PR format

Title: `[<package_name>] <description>`
```
