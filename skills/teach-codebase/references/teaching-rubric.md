# Teaching Rubric

The investigation can be exhaustive. The lesson should be selective.

## Start with a usable mental model

Open with one or two plain paragraphs that answer:

- what is this thing;
- what job does it do in this codebase;
- what are the few moving pieces needed to understand the rest.

Do not begin with a directory tree, dependency list, or glossary dump.

## Teach from concrete behavior

Anchor architecture in an actual flow. Prefer:

```txt
user/event/request
  -> entrypoint
  -> application/domain behavior
  -> boundary / side effect
  -> observable result
```

Explain what each step contributes. A list of function names is reference material, not teaching.

## Layer the explanation

For substantial requests, add depth in this order when relevant:

1. mental model;
2. vocabulary/domain concepts;
3. architecture and ownership;
4. golden path;
5. data transformations and contracts;
6. state ownership;
7. I/O and side effects;
8. errors/failure paths;
9. tests;
10. rationale/gotchas;
11. change guidance.

Skip layers that do not help answer the user's question.

## Make boundaries visible

Call out representation and ownership changes explicitly:

```txt
unknown JSON
  -> request DTO
  -> validated command
  -> domain value
  -> persistence DTO
```

Likewise distinguish state categories when they matter: UI/form state, URL state, server/cache state, process state, persistent state, queue/event state, external-system state.

## Teach failures, not only happy paths

When reachable, explain what happens for:

- validation failure;
- domain rejection;
- missing data;
- network/storage failure;
- timeout;
- retry;
- cancellation;
- partial success;
- stale/cache conflict;
- authorization failure.

The reader should know where failures originate and where they become user/protocol-visible errors.

## Use tests as reading paths

When useful, end a section with a small set of tests that demonstrate the behavior better than more prose. Explain why each test is worth reading.

## Diagrams

Use diagrams when three or more moving parts would otherwise be hard to hold in working memory.

Prefer progressive diagrams for complex systems. Redraw the previous picture and add one meaningful piece at a time. Avoid giant all-at-once architecture maps.

Text diagrams are usually enough for call stacks and ownership maps.

## Change-oriented guidance

When the user is learning before making a change, finish with a practical map:

```txt
Preserve
- invariants / contracts

Likely touch
- files / modules

Read or run
- representative tests

Watch
- side effects / downstream consumers / runtime semantics

Unknown
- questions that need evidence before editing
```

Do not turn this into an implementation plan unless requested.

## Style

Write like a senior engineer onboarding a colleague.

- Concrete mechanism over metaphor.
- Stable project terminology over synonyms.
- Specific files/symbols over vague references.
- Small complete explanation before deep detail.
- No exhaustive inventories unless the user asks for reference documentation.
- Preserve uncertainty. Do not make the prose more confident than the evidence.
