# Consensus: unified `teach-codebase` skill

## Decision

Start from Grok's PR #2 structure. Bring in Codex's evidence rules, rationale confidence classes, state ownership, tests-as-evidence, and change-ready output. Do not merge either PR unchanged.

Grok has the better teaching loop. It selects a mode, produces a useful first answer, and stops before an onboarding request becomes an audit. Codex has the better investigation discipline. It makes the explanation traceable to code and keeps unknowns from becoming invented behavior.

The skill teaches the current system. It does not implement a change, write a spec, redesign a module, quiz the user, or write repository files unless the user asks for a saved artifact.

## Decisions that both reviews support

| Area | Consensus |
| --- | --- |
| Outer structure | Use PR #2's modes, specialist roles, typed hop table, teaching voice, and optional mental-model template. |
| Evidence | Use PR #1's rule that material claims cite `file:symbol`. A filename or framework convention is a lead, not proof. |
| Unknowns | Stop at an unavailable boundary and mark an open question. Do not fill the gap with plausible glue. |
| Rationale | Keep PR #1's direct, supported, inferred, speculative, and unknown confidence classes. Code can show behavior without proving intent. |
| State and tests | Trace state ownership and representation changes when they affect the path. Read tests as protected behavior, then reconcile them with code and docs. |
| Vocabulary | Use the repository's words first. Point to `codebase-design` for module terms instead of copying its glossary. |
| Persistence | Conversation is the default. Use `MENTAL-MODEL.template.md` only after an explicit request to save a map. |
| Invocation | Keep Grok's trigger-rich description and omit `disable-model-invocation`. Natural requests to understand a codebase should select this skill. |

## Resolve the remaining disagreements

### Teaching depth follows the request

Keep Grok's first-layer rule for a broad request such as "teach me this repository." Give the smallest coherent map, one or more representative paths, a short glossary, and concrete next cuts.

Do not apply that stop rule to an explicit bounded request. If the user asks for a complete trace or a change-readiness review, complete that requested scope in the current reply. Progressive teaching means adding no unrelated layers, not withholding the layer they requested.

### Explore narrowly before delegating

Keep Codex's distinction between exploration direction and teaching mode:

- Start top-down for a repository or subsystem.
- Start bottom-up from a named file or symbol, then walk outward.
- Use change-oriented exploration for an upcoming edit.

For one function or one file, investigate and teach in one pass. For a subsystem or a cross-cutting path, use two to four independent specialist slices when that improves coverage. If specialists are used, the primary agent reconciles their evidence and writes the answer. A separate Teacher agent is optional, not required.

This retains Grok's bounded specialist schemas without creating an unnecessary handoff that can lose qualifications from the user request.

### Make modes specify outputs, not a fixed lesson length

| Mode | First deliverable |
| --- | --- |
| Onboard | Smallest coherent system map, one primary trace, glossary, and next cuts. |
| Map | Contexts, entrypoints, ownership, seams, and external systems. |
| Trace | One evidence-backed hop table, including failures and effects. |
| Module | Interface, invariants, callers, dependencies, tests, adapters, and leaks. |
| Change-ready | Preserve, likely touch, tests, blast radius, effects, and unknowns. |
| Reconcile | Confirmed claims, contradictions, corrections, and unresolved claims. |

The mode chooses the first deliverable. The user's wording chooses how deep to go.

### Put detailed rules in the references that own them

Keep `SKILL.md` as an orchestrator of roughly 140 to 180 lines. It should route intent, scope, complexity, and sibling handoffs. It should link to detailed rules instead of restating them.

Use this package layout:

```text
skills/teach-codebase/
├── SKILL.md
├── agents/openai.yaml
├── assets/
│   └── MENTAL-MODEL.template.md
└── references/
    ├── agent-prompts.md
    ├── investigation-contract.md
    ├── callstack-format.md
    ├── rationale-epistemics.md
    └── teaching-voice.md
```

Remove `architecture-vocab.md`. Do not add a second teaching-rubric ladder. One format owns the call stack, and one sibling skill owns the architecture vocabulary.

## Required reference responsibilities

`investigation-contract.md` sets the evidence posture. Every material hop is opened in implementation and recorded as `file:symbol`. It tells investigators to preserve contradictions, trace only relevant inputs, outputs, errors, state, I/O, and effects, and stop at an explicit gap.

`callstack-format.md` owns the typed hop table: symbol, input, output, errors, effects, and evidence. It adds state reads and writes, representation changes across seams, and separate stacks for failure, retry, cancellation, idempotency, authorization, and observability when those apply. Use project types. If the code uses strings, say strings.

`agent-prompts.md` keeps Grok's bounded roles and adds Codex's fields. The Tracer owns I/O, state, representations, tests, retry behavior, authorization, and observability. The Linguist records term conflicts, special IDs, and status transitions. The Seam mapper uses `codebase-design` terms without duplicating their definitions. The Historian uses the rationale confidence classes and treats a searched-but-empty history as a result.

`rationale-epistemics.md` is the sole definition of confidence language. It forbids claiming motive from code shape alone.

`teaching-voice.md` owns density, diagrams, forbidden stock phrases, and the Change-ready map. Its governing rule is simple: investigation may be exhaustive, but the explanation is one useful layer of that investigation.

## Specialist routing

| Mode | Specialists, when the scope warrants them |
| --- | --- |
| Onboard | Cartographer, Linguist, and Tracer for one or more representative paths. |
| Map | Cartographer, Linguist, and Seam mapper. |
| Trace | Tracer. |
| Module | Seam mapper and Linguist. Add Tracer only for a necessary runtime path. |
| Change-ready | Tracer and Seam mapper. Add Historian only when a constraint needs explanation. |
| Reconcile | Tracer against the stated model. Add Linguist for term conflicts. |
| Why or unusual shape | Historian, with a narrow question. |

Do not spawn agents to fill a template. When subagents are unavailable, perform the same bounded slices sequentially.

## Handoffs

- Use `type-spec` after the user understands the current system and wants to design a change.
- Use `codebase-design` to reshape a module. `teach-codebase` only uses its terms to describe the current shape.
- Use `grill-me` when the user needs to examine a new design with thin context.
- Run `unslop` on the final explanation before sending it.

## Implementation order

1. Use PR #2 as the file and routing baseline.
2. Replace its broad investigation guidance with a compact PR #1 evidence contract.
3. Add rationale confidence, state ownership, representation changes, tests-as-evidence, and the explicit Change-ready map.
4. Remove automatic persistence, the copied architecture vocabulary, and the mandatory Teacher handoff.
5. Change "stop after layer 1" to apply only to broad or underspecified requests.

This produces a skill that is easy to invoke and teach from, with claims that remain grounded in the code.
