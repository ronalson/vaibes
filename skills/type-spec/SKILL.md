---
name: type-spec
description: Write a typed call-stack architecture handoff.
disable-model-invocation: true
---

# Type Spec

A tech spec is a **typed call-stack architecture handoff**: code-shaped contracts plus execution flows. Prefer TypeScript pseudocode over prose wherever precision matters.

This skill is design-only. Do not implement. Save a file only when the user asks for a file; otherwise return the spec inline.

## Branch selection

1. Use **Path A: Convert context to spec** when the conversation, docs, or codebase already contain enough background to describe the change.
2. Use **Path B: Grill first** when the user wants a new spec but has not provided enough problem, constraints, design direction, affected code, or acceptance criteria.

If a question can be answered by exploring the codebase, inspect the codebase instead of asking.

## Path A: Convert context to spec

### 1. Load standards and local context

Inspect existing code and docs for local vocabulary, module layout, domain concepts, errors, adapters, observability, runtime patterns, and test style. Before introducing a pattern, library, adapter, schema style, or test strategy, check local precedent; if none applies, record that as an open question or a deliberate proposal.

### 2. Extract the design problem

Capture:

- current state;
- problem;
- users/callers;
- goals;
- non-goals;
- constraints;
- invariants;
- affected systems;
- likely entrypoints;
- operational/runtime concerns;
- risks;
- open questions.

Mark unknowns as open questions instead of filling gaps with plausible design.

### 3. Explore alternatives when needed

When a material design choice remains unresolved, compare materially different alternatives. They should differ in interface shape, seam placement, ownership, call stack, runtime topology, or module boundaries, not just names. Use `codebase-design` and [DESIGN-IT-TWICE.md](../codebase-design/DESIGN-IT-TWICE.md) when they help assess the choice. Develop alternatives in one pass unless independent parallel exploration would add useful evidence.

If the design is already agreed, record that decision and proceed without inventing alternatives.

For each alternative, sketch:

- domain types and state model;
- public/module interfaces and APIs;
- input/output types;
- expected failure types;
- seams, boundaries, and adapters;
- entrypoint-to-side-effect call stack;
- parsing/projection strategy;
- authorization, observability, cancellation, idempotency, and transaction flow when reachable;
- test seam strategy;
- tradeoffs.

Compare alternatives on:

- caller burden;
- module depth and leverage;
- locality of invariants and change;
- seam placement;
- boundary parsing and projections;
- error and cancellation model;
- testability through real seams;
- operational/runtime fit;
- implementation complexity.

### 4. Specify the recommended typed contracts

For the recommended design, outline every new, changed, or deleted:

- domain value;
- branded/refined type;
- state machine variant;
- input/output type;
- request/response shape;
- function signature;
- class or module interface;
- expected-failure/custom-error type;
- adapter interface;
- protocol DTO;
- persistence DTO/projection;
- runtime-boundary codec;
- public API.

Name seams, adapters, implementations, ownership boundaries, and what crosses each boundary. State what each layer may know and what must not leak across the seam.

Map every planned contract to its owning file or module, or an explicit open question.

### 5. Specify call stacks and data flow

For every new, changed, or deleted behavior, show the call stack from entrypoint to side effects and response.

Include type/data flow:

```txt
raw input
  -> boundary DTO / unknown
  -> parser
  -> canonical domain/application input
  -> service/module interface
  -> adapter call
  -> typed result/error
  -> projection
  -> serialized output
```

Include current vs proposed flow when changing existing behavior. Include failure, retry, cancellation, transactionality, idempotency, observability, authorization, and runtime-hop flow when reachable.

Map every meaningful call-stack step to a file or module, or an explicit open question.

### 6. Map files and modules

List:

- files/modules to add;
- files/modules to change;
- files/modules to delete, if any;
- test files;
- config/migration/runtime files, if any.

For each file, state the contract, code path, boundary, adapter, domain concept, or test responsibility it owns.

### 7. Write the RGR TDD test plan

Use the sibling TDD workflow and testing standards. Plan vertical Red-Green-Refactor slices: one failing behavior test, minimal implementation, refactor without changing behavior, rerun the affected tests, then repeat. Do not write a horizontal "all tests first, all code later" plan.

Favor behavior through public interfaces and real seams over implementation-coupled mocks.

Cover proportionately, based on meaningful behavior and likely failures:

- happy paths;
- failure paths;
- parser rejection and accepted shapes;
- domain invariants and state transitions;
- adapter contracts;
- persistence/runtime semantics;
- cancellation/retry/idempotency paths;
- observability and safe summaries where relevant;
- end-to-end flows for high-consequence behavior.

### 8. Produce the spec

Return the spec inline unless the user requested a file path. If a file was requested, save it there.

Do not implement and do not ask to implement by default.

## Path B: Grill first

1. Do not write a full spec yet.
   - State that there is not enough context for an implementation-ready tech spec.
2. Start a grilling interview. Use `grill-me`.
   - Ask the current frontier of independent, material questions as a round, with a recommended answer for each.
   - If a question can be answered by exploring the codebase, inspect the codebase instead of asking.
3. Convert to the spec.
   - Once grilling context is sufficient, run Path A.

## Spec template

Start from [templates/type-spec.md](templates/type-spec.md) when a full structure helps. Omit sections that do not apply, but retain the contracts, call stacks, and tests needed to make the design safe to implement.

## Writing rules

- Code first: TypeScript pseudocode defines contracts, APIs, and data flow.
- Prose explains why; types and call stacks define what changes.
- Focus on types, interfaces, APIs, inputs/outputs, seams, boundaries, adapters, domain modules, service modules, external adapters, and call stacks.
- Prefer precise domain values over strings, booleans, nullable bags, and loosely shaped objects.
- Keep seams real: adapters translate framework, persistence, network, time, randomness, telemetry, runtime, or platform boundaries.
- Avoid speculative abstraction; every seam earns its existence through invariants, locality, leverage, testing, or a real boundary.
- Keep a single source of truth; do not restate the same rule in multiple sections unless one section points to the other.
- Unknowns stay open questions. Do not invent product requirements, domain rules, APIs, or call stacks to make the spec feel complete.

## Completion

Finish with a design-only handoff that uses local vocabulary, grounds requirements in local precedent, evidence, or open questions, preserves agreed decisions, and gives unresolved material choices enough evidence for a recommendation. Include the contracts, call stacks, file mapping, and proportionate test plan needed for another engineer to implement the change safely.
