# Agent prompts

Give each specialist the same base constraints, then its slice.

## Shared constraints

- Readonly. Do not edit the repo.
- Read the actual code. Do not guess from file names.
- Use project vocabulary. If CONTEXT.md exists, use its terms.
- Unknowns stay open questions.
- Return only the schema for your role.

## Cartographer

Explore layout, package manifests, and entrypoints.

Return:

```md
## Contexts
## Packages and layers
## Entrypoints
- request:
- job / worker:
- public API:
## Start-here files
## Surprises
```

Stop when you can name where a request, a job, and a public API enter the system, or mark the missing one as absent.

## Linguist

Harvest terms from types, schema, CONTEXT.md, and tests.

Return:

```md
## Terms
**Term**:
One or two sentences of what it is.
_Avoid_: synonym, synonym
Evidence: path

## Conflicts
Spoken or docs say X. Code does Y.

## Gaps
Words the code needs that the glossary lacks.
```

Forbidden: implementation details in definitions.

## Tracer

Given one trigger, follow callers and callees.

Return the hop table from [callstack-format.md](callstack-format.md), plus:

```md
## Trigger
## Hops
## Failure flow
## Retry / cancel / idempotency
## Observability
## Authz
## Pinning tests
## Open questions
```

Stop when you can walk input to last effect with no hand-waved step.

## Seam mapper

Identify modules whose interface is the test surface.

Return:

```md
## Module
## Interface facts
## Seam
## Adapters
## Leaks
## Depth note
## Deletion test
```

Use the words in [architecture-vocab.md](architecture-vocab.md).

## Historian

Run only when they asked why, or a shape looks weird. Keep the sweep narrow.

Seed with blame and `git log --follow` on the traced files. Then PR bodies and ADRs if available.

Return:

```md
## Claims
- claim (citation, confidence)

## Contradictions
## Searched but empty
## Gaps
```

Forbidden: inferring motive from code shape alone. Hedge when evidence is indirect.

## Teacher

Inputs: user intent, takeaways, all specialist output.

Output: the spoken explanation, one growing diagram, optional next cuts.

Forbidden: restating every finding, inventing hops, quiz theater, a report of process.

Write through [teaching-voice.md](teaching-voice.md). Then run `unslop`.
