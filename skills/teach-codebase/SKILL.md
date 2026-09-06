---
name: teach-codebase
description: Explain an existing codebase, subsystem, runtime path, or symbol so the user can change it safely.
disable-model-invocation: true
---

# Teach codebase

Teach the current system without changing it. Do not write a spec, redesign a module, or quiz the user. Reply in the conversation unless the user explicitly asks for a saved map.

## Start from the target

Read applicable repository instructions first. Then explore the smallest slice that answers the request:

- Start at a named file or symbol and walk outward.
- For a repository or subsystem, find the relevant entrypoint and one coherent path.
- For a planned change, trace the behavior it would affect, its seam, protected tests, effects, and unknowns.

Treat file names and conventions as leads, not proof. Open the code, configuration, tests, and documentation behind each material claim. Read [investigation-contract.md](references/investigation-contract.md) when the requested path is non-trivial. Read [rationale-epistemics.md](references/rationale-epistemics.md) only for a why question or non-obvious constraint.

## Choose depth that fits

| Request | Deliverable |
| --- | --- |
| Onboard or map | A small system map, one primary path, and focused next cuts. |
| Trace | An evidence-backed path with inputs, outputs, errors, effects, and tests that matter. |
| Module | Interface, callers, dependencies, invariants, adapters, and leaks. |
| Change-ready | Preserve, likely touch, tests, downstream effects, and unknowns. |
| Reconcile | Confirmed claims, corrections, contradictions, and unresolved claims. |

Use [callstack-format.md](references/callstack-format.md) for a trace when its hop table clarifies the answer. Load the `codebase-design` glossary only when explaining module shape. Delegate read-only exploration only when independent slices would materially help; otherwise investigate sequentially. Use [agent-prompts.md](references/agent-prompts.md) only when delegating.

## Explain what the evidence supports

Lead with the thing and its mechanism, not a file tour. Use project terms and distinguish direct evidence, supported conclusions, inference, and unknowns. Each material trace hop must name `file:symbol` or an open question. Cover representations, state, I/O, errors, effects, and tests only where they affect the requested path.

Use a visual only when it makes three or more relationships clearer. `show-me` can provide that visual, but it is optional and does not require the `html-doc` workflow.

For substantial, broad, or change-ready explanations, read [teaching-voice.md](references/teaching-voice.md) before drafting so the explanation stays at one useful layer and ends a change-ready answer with the required preservation and risk summary.

## Finish at the requested boundary

For a broad request, stop after the first useful layer and offer focused next cuts. For a bounded request, finish the requested path, module, or change map in the current reply. If the user asks for a saved map, use [MENTAL-MODEL.template.md](assets/MENTAL-MODEL.template.md); otherwise do not create or update repository context files.
