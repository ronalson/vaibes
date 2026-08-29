---
name: teach-codebase
description: Teach a person a codebase so they can change it safely. Builds domain language, module seams, and typed call stacks with I/O, errors, and side effects. Use for teach me this codebase, help me understand this repo, onboard me onto this subsystem, how does this path work, walk me through this request, where does X live, what happens when a user does Y.
---

# Teach codebase

Explain what a body of code is, how it runs, and why it is shaped that way, so the person can change it without guessing. Do not implement. Do not write a spec unless they ask. Teaching is the product.

This skill sits next to `type-spec` and `codebase-design`. Those design a change. This one teaches the current system so a later spec or edit is grounded. After the explanation, call `unslop` on the prose.

## What this is not

- A file-tree tour or README paraphrase
- A typed spec for a proposed change (`type-spec`)
- A redesign of a module interface (`codebase-design`)
- A quiz, lecture theater, or wall of function names

## Modes

Read why they are asking from the conversation. Do not quiz.

| Mode | When | First deliverable |
| --- | --- | --- |
| Onboard | New to the repo or a large subsystem | Map + 2-3 critical traces + glossary |
| Map | Architecture and language only | Contexts, packages, seams, where things live |
| Trace | What happens when X | One typed call stack with I/O, errors, effects |
| Module | One module | Interface, depth, adapters, invariants, tests-as-docs |
| Change-ready | About to edit | Blast radius, invariants, the stack that will move |
| Reconcile | They have a story | Check it against code and name contradictions |

Default for "teach me this codebase" with no target: Onboard the smallest coherent system (app entry + one core domain), not the whole monorepo.

## Flow

```
intent + scope
  -> inventory
  -> specialists (only what this mode needs)
  -> teacher writes layer 1
  -> stop
  -> deepen on their next ask
  -> persist only if they ask or a term is resolved
```

### 1. Inventory

Before spawning anyone:

- Detect language, package manager, app kind (library, service, monorepo, CLI).
- Find entrypoints: `main`, route tables, workers, cron, public exports.
- Read `CONTEXT.md`, `CONTEXT-MAP.md`, and relevant ADRs if present. If absent, proceed silently.
- Note test layout and observability so traces use local vocabulary.

Do not invent a glossary or architecture the repo already named.

### 2. Pick 3-5 takeaways

Choose them from intent (onboard, debug, review, about to change) and what they already showed they know. Skip the rest. Put depth where their question is.

### 3. Fan out specialists

One function or one file: explore and teach in a single pass.

A subsystem or cross-cutting path: spawn 2-4 parallel readonly explorers, then one teacher. When in doubt, lean simple.

Use the prompts in [references/agent-prompts.md](references/agent-prompts.md). Spawn only the slices this mode needs:

| Agent | Job |
| --- | --- |
| Cartographer | Packages, layers, entrypoints, where things live |
| Linguist | Domain terms from types, schema, CONTEXT.md, tests |
| Tracer | One behavior, entrypoint to response and effects |
| Seam mapper | Modules, interfaces, adapters, leaks, depth |
| Historian | Why, only if they asked or a shape looks weird |
| Teacher | Runs last. Never re-explores. Writes the human explanation |

Each specialist returns the schema in the prompt. Overlap is fine. The teacher reconciles. A hop that was not opened in code is an open question, not a guess.

### 4. First reply is a layer

- Name the thing in one or two sentences, then tie it to this repo.
- Explain the mechanism. Do not list functions as a tour.
- One diagram that adds one idea. Grow the picture on later turns.
- Offer two or three concrete next cuts. Stop.

Do not print framing labels ("the key insight", "TL;DR", "the thing to walk away with"). Do not quiz. Do not announce pauses.

Use [references/teaching-voice.md](references/teaching-voice.md).

### 5. Persist only when it pays

Default output is the conversation. Write a file when they ask to save the map, a term is resolved and `CONTEXT.md` is missing or stale, or they will work here across sessions.

If writing a map, use [assets/MENTAL-MODEL.template.md](assets/MENTAL-MODEL.template.md). Glossary sections stay free of implementation details.

## Teaching objects

### Call stack

Every Trace, and every Onboard critical path, uses [references/callstack-format.md](references/callstack-format.md). Prefer typed pseudocode in the repo's language.

Completion rule: every hop is a real function or module you opened, or it is marked open question. No plausible glue.

### Architecture

Use the words in [references/architecture-vocab.md](references/architecture-vocab.md) exactly. They match `codebase-design`.

For each important module name the interface (signature plus invariants, errors, ordering, config), the seam, the adapters, and what must not leak. Run the deletion test out loud. One adapter means the seam is still hypothetical. Two means it is real.

### Domain language

Define what a term *is*, not what it does. Project words only. List rejected synonyms under `_Avoid_`. If spoken language and code disagree, that contradiction is the lesson. Do not silently pick a side.

## Sibling skills

- Need a change designed after they understand it: `type-spec`
- Need to reshape a module: `codebase-design`
- Context is too thin and they want a new design, not a tour: `grill-me`
- Before sending the explanation: `unslop`

## Reply

Lead with the explanation. Never a report about what you did. After the first layer, offer next cuts as actions they can request:

- Trace `POST /checkout` including payment effects
- Map the inventory seam and its adapters
- Why this outbox exists (git and ADRs only)
