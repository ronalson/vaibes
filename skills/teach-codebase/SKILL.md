---
name: teach-codebase
description: Teach a person an existing codebase, subsystem, runtime path, or symbol so they can change it safely. Use for teach me this codebase, help me understand this repo, onboard me onto this subsystem, how does this path work, walk me through this request, where does X live, or what happens when a user does Y.
---

# Teach codebase

Teach the current system so a later `type-spec` or edit is grounded. Do not implement, write a spec, redesign a module, or quiz the user.

The conversation is the default output. Write a mental-model file only when the user explicitly asks for one.

## Route the request

Read the user's intent from the conversation. Do not interrogate them. If the scope is ambiguous, state the interpretation and proceed.

If the user names a file or symbol, start there and walk outward. Use a top-down reading for a repository or subsystem. Use a change-oriented reading when the user plans an edit.

| Mode | When | First deliverable |
| --- | --- | --- |
| Onboard | New to the repo or a large subsystem | Smallest coherent system map, one primary trace, glossary, and next cuts. |
| Map | They need architecture and language | Contexts, entrypoints, ownership, seams, and external systems. |
| Trace | They ask what happens when X | One evidence-backed hop table with failures and effects. |
| Module | They name a module | Interface, invariants, callers, dependencies, tests, adapters, and leaks. |
| Change-ready | They plan an edit | Preserve, likely touch, tests, blast radius, effects, and unknowns. |
| Reconcile | They bring an existing model | Confirmed claims, contradictions, corrections, and unresolved claims. |

For a bare "teach me this codebase," use Onboard for the smallest coherent system, not the whole monorepo.

The mode selects the first deliverable. The request sets the depth. For a broad request, give one complete layer and offer next cuts. For an explicit trace or change-ready request, finish the requested scope in the current reply.

## Orient before tracing

Before exploring, identify the language, package manager, application kind, entrypoints, test layout, and local observability names. Read `AGENTS.md`, `CLAUDE.md`, `CONTEXT.md`, `CONTEXT-MAP.md`, the README, and relevant ADRs when present. If a file is absent, continue.

Treat folders and framework conventions as leads. Do not treat them as proof of ownership or runtime behavior. Use the repository's vocabulary. Do not invent a glossary that the codebase did not name.

Read [investigation-contract.md](references/investigation-contract.md) before investigating. Read [rationale-epistemics.md](references/rationale-epistemics.md) before explaining why a design exists.

For an Onboard or Map request, identify the request, job or worker, and public API entrypoints that exist. For a Trace, Module, or Change-ready request, inventory only the entrypoints and tests needed for that target.

## Investigate only the needed slices

For one function or file, explore and teach in one pass. For a subsystem or cross-cutting path, use two to four independent, read-only specialists when that improves the answer. Do not delegate to fill a template. If specialists are unavailable, perform the same slices sequentially.

| Mode | Specialists, when the scope warrants them |
| --- | --- |
| Onboard | Cartographer, Linguist, and Tracer for representative paths. |
| Map | Cartographer, Linguist, and Seam mapper. |
| Trace | Tracer. |
| Module | Seam mapper and Linguist. Add Tracer for a necessary runtime path. |
| Change-ready | Tracer and Seam mapper. Add Historian for a constraint that needs explanation. |
| Reconcile | Tracer against the stated model. Add Linguist for term conflicts. |
| Why or unusual shape | Historian, with a narrow question. |

Use [agent-prompts.md](references/agent-prompts.md) for the specialist schemas. Reconcile the evidence before writing. The primary agent writes the explanation. Do not require a separate Teacher handoff.

## Teach one useful layer

Lead with one or two sentences that name the thing in this repository. Explain its mechanism instead of touring functions. Anchor broad explanations in a real behavior.

Every Trace and primary Onboard path uses [callstack-format.md](references/callstack-format.md). Every material hop is `file:symbol` or **open question**. State representations, state ownership, I/O, effects, errors, and tests when they matter to the path.

Use project terms. Before describing module shape, read the `codebase-design` glossary. Then use its terms precisely: module, interface, implementation, seam, adapter, depth, leverage, and locality. Do not rename project concepts to fit those terms.

Use one diagram only when it makes three or more relationships easier to understand. For broad requests, offer focused next cuts and stop. Do not offer next cuts instead of completing an explicit request.

Follow [teaching-voice.md](references/teaching-voice.md), then run `unslop` on the final prose.

## Save only on request

If the user asks to save the map, use [MENTAL-MODEL.template.md](assets/MENTAL-MODEL.template.md). Keep glossary entries free of implementation detail. Do not create or update `CONTEXT.md` as a side effect of teaching.

## Completion rule

Finish when the requested deliverable is grounded in opened code, every material gap is visible, and the explanation has no invented hop. For a broad request, stop after the first useful layer. For a bounded request, stop after the requested path, module, or change map is complete.

## Hand off at the right point

- Use `type-spec` when the user understands the current system and wants to design a change.
- Use `codebase-design` when the user wants to reshape a module.
- Use `grill-me` when the user has thin context and needs to examine a new design.
