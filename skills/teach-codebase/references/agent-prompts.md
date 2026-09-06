# Specialist prompts

Use these prompts only when independent, read-only exploration would materially help. Give every specialist the constraints in [investigation-contract.md](investigation-contract.md). Specialists return evidence, contradictions, and open questions. They do not write the lesson.

## Cartographer

Explore repository layout, package manifests, entrypoints, and external systems.

```md
## Contexts
## Packages and layers
## Entrypoints
- request:
- job or worker:
- public API:
## Start-here files
## Evidence
## Contradictions
## Open questions
```

Stop when you can name where relevant execution enters the system, or mark the entrypoint absent.

Do not infer ownership from a directory name. Name a package or layer only when its exports, callers, configuration, or implementation support the claim.

## Linguist

Harvest project terms from types, schema, docs, and tests. Define what each term is, not how its implementation works. Record IDs with special meaning and status or state-machine transitions.

```md
## Terms
**Term**
Definition.
_Avoid_: rejected synonym
Evidence: `file:symbol`

## Conflicts
## Gaps
## Evidence
## Contradictions
## Open questions
```

## Tracer

Follow one trigger through callers, callees, representations, state, I/O, and effects. Return a hop table when it clarifies the trace, then add only the relevant sections below:

```md
## Failure flow
## Retry, cancellation, and idempotency
## Observability
## Authorization
## Pinning tests
## Evidence
## Contradictions
## Open questions
```

Stop at the last effect that code proves, or an explicit gap.

Include inputs, outputs, errors, effects, evidence, representation changes, and state reads or writes that matter to the path. Read tests around the public seam before calling the trace complete.

## Seam mapper

Describe current module shape. Use `codebase-design` terms, but do not reproduce its definitions.

```md
## Module
## Interface facts
## Seam
## Adapters
## Representations across the seam
## Leaks
## Depth note
## Deletion test
## Tests that pin the interface
## Evidence
## Contradictions
## Open questions
```

## Historian

Run only for a why question or a non-obvious constraint. Search narrow local evidence first: comments, ADRs, `git log --follow`, blame, commits, and PRs.

```md
## Claims
- claim — citation — direct, supported, inferred, speculative, or unknown
## Searched but empty
## Contradictions
## Open questions
```

Do not infer motive from code shape alone. See [rationale-epistemics.md](rationale-epistemics.md).

Do not search history by default. Use the Historian only when the user asks why, an arbitrary-looking value constrains the path, or a planned edit could violate a non-obvious rule.
