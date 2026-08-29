---
name: teach-codebase
description: Build a working mental model of an unfamiliar codebase, subsystem, feature, runtime flow, or symbol. Maps domain concepts, architecture, call stacks, data transformations, state, I/O, side effects, failures, tests, and evidence-backed rationale. Read-only.
disable-model-invocation: true
---

# Teach Codebase

Teach an existing codebase deeply enough that the user can navigate it, reason about it, and change it safely. The goal is a **working mental model**, not a file inventory or annotated source dump.

This skill is read-only. Do not modify the target codebase unless the user separately asks for implementation work.

Read [references/investigation-contract.md](./references/investigation-contract.md) before exploring. Read [references/teaching-rubric.md](./references/teaching-rubric.md) before writing the final explanation. Use [references/rationale-epistemics.md](./references/rationale-epistemics.md) whenever explaining why code is shaped a particular way.

## 1. Infer the learning target

Classify the request without interrogating the user when the codebase can answer it.

Target:

- whole repository;
- subsystem or domain;
- feature or user flow;
- runtime path;
- file, class, function, hook, component, or other symbol.

Intent:

- onboarding;
- preparing to modify code;
- debugging;
- reviewing a change;
- general understanding.

Choose an exploration direction:

- **Top-down** for repositories and subsystems: repository -> runtime -> domains/modules -> golden paths -> implementation.
- **Bottom-up** for symbols/files: target -> dependencies/callers -> owning module -> runtime flow -> domain purpose.
- **Change-oriented** when the user plans to modify something: prioritize invariants, contracts, tests, side effects, downstream consumers, and blast radius.

If scope is ambiguous, state the best interpretation briefly and proceed. Let the user redirect.

Completion criterion: the exploration has a concrete target, intent, and direction.

## 2. Orient before tracing

Read repository instructions and the smallest useful set of orientation material:

- `AGENTS.md`, `CLAUDE.md`, `CONTEXT.md`, `CONTEXT-MAP.md`;
- `README`, contribution docs, ADRs, architecture docs;
- manifests/workspace configuration;
- build and test configuration;
- app/process entrypoints;
- routes, handlers, commands, consumers, jobs, or UI roots relevant to the target.

Build an internal repository fingerprint:

- languages and runtimes;
- frameworks;
- applications/packages;
- entrypoints;
- external systems;
- likely domains;
- test strategy;
- existing terminology and architecture documentation.

Do not treat folders as architecture merely because they exist.

Completion criterion: exploration uses the project's vocabulary and knows where execution begins.

## 3. Assess complexity and fan out adaptively

Prefer the smallest investigation that can produce an end-to-end explanation.

### Small target

For a narrow function, component, hook, utility, or module, explore directly in one pass.

### Medium target

For a feature or subsystem spanning several files, use up to three read-only exploration angles:

1. architecture/domain ownership;
2. runtime/data/error flow;
3. tests and behavior contracts.

### Large target

For a broad subsystem or whole repository, use up to five read-only exploration angles:

1. **Cartography** — applications, modules, ownership, boundaries, entrypoints, external systems.
2. **Runtime tracing** — golden paths, call stacks, inputs/outputs, data transformations, errors.
3. **Domain/state** — project vocabulary, invariants, state machines, state ownership.
4. **I/O and side effects** — persistence, network, files, queues, events, telemetry, cache mutation, async/runtime hops.
5. **Tests** — executable contracts, edge cases, fixtures, failure expectations, useful starting tests.

When the environment supports subagents, run distinct angles in parallel and keep every investigator read-only. Give each investigator the same contract from `references/investigation-contract.md` plus its assigned angle. If subagents are unavailable, perform the same slices sequentially.

Do not spawn agents merely to satisfy a template. A single good trace is better than five shallow summaries.

Completion criterion: every active exploration angle owns a distinct question and returns evidence, not polished prose.

## 4. Identify the golden paths

For repositories and substantial subsystems, find the 2-5 flows that explain most of the system. Prefer real user, request, event, command, or background-job behavior over directory tours.

Examples:

- sign in;
- load dashboard;
- submit form;
- create order;
- process payment;
- consume event;
- reconcile background job.

Choose the path most relevant to the user's intent as the primary teaching path. Use the others to establish the surrounding architecture.

Completion criterion: the explanation has at least one concrete end-to-end behavior to anchor abstract architecture.

## 5. Trace behavior end to end

For each important flow, trace from trigger to observable result. Follow actual callers, callees, types, and boundaries. Do not hand-wave with phrases such as "then the service handles it."

Capture:

```txt
trigger
  -> entrypoint
  -> boundary input
  -> parsing / validation
  -> canonical application/domain input
  -> module/service call
  -> state reads
  -> decision points / invariants
  -> adapter / I/O boundary
  -> state writes / side effects
  -> projection / serialization
  -> observable result
```

Also trace reachable:

- expected errors and where they become user/protocol errors;
- retries, cancellation, timeouts, idempotency, transactions;
- authorization;
- cache invalidation;
- events, analytics, logging, email, notifications;
- process/thread/runtime hops.

For each important step, record the symbol and file. Include types where they clarify contracts; do not turn the lesson into a type dump.

Completion criterion: the main flow can be described from input/trigger to output/effect without an unexplained hop.

## 6. Build the domain and state model

Extract the vocabulary the codebase actually uses. Prefer project terminology over imported architecture jargon.

Look for:

- important nouns and IDs;
- entities/value objects/domain values;
- statuses and state-machine transitions;
- relationships between concepts;
- invariants;
- overloaded or misleading terms;
- boundaries where the same concept changes representation.

Cross-check claims against code. If docs and code disagree, surface the contradiction instead of silently choosing one.

Map state ownership explicitly when relevant:

```txt
local/UI state
server/cache state
URL/navigation state
process memory
persistent storage
queue/event state
external-system state
```

Completion criterion: a newcomer can name the core concepts, say who owns important state, and identify at least the key invariants.

## 7. Read tests as executable documentation

Find the tests that best demonstrate the target's behavior. Prefer tests around public seams, integration paths, edge cases, and failures over implementation-detail snapshots.

Extract:

- happy-path behavior;
- expected failures;
- domain invariants;
- lifecycle/state transitions;
- retry/idempotency/runtime semantics;
- fixture vocabulary;
- external contracts.

Identify a short "read these first" set when useful.

Do not assume a behavior is required solely because a test asserts it. Treat tests as strong evidence of protected behavior, then reconcile them with implementation and docs.

Completion criterion: important behavior claims are backed by implementation, tests, or both.

## 8. Investigate rationale only when it matters

Code proves what happens more reliably than why it was chosen. Investigate historical rationale when:

- the user asks why;
- a workaround or odd pattern is central to understanding;
- an arbitrary-looking threshold or invariant matters;
- the planned change could violate a non-obvious constraint.

Start with local evidence:

- comments;
- ADRs/docs;
- git history and blame;
- commits and PR discussion;
- linked issues.

Use connected external sources only when available and warranted.

Classify rationale claims using `references/rationale-epistemics.md` as **direct**, **supported**, **inferred**, **speculative**, or **unknown**. Preserve uncertainty in the final explanation.

Never infer intent from code shape and present it as fact.

Completion criterion: rationale is either evidence-backed with calibrated confidence or explicitly unknown.

## 9. Synthesize evidence before teaching

When multiple investigators were used, combine their findings into one evidence packet before writing user-facing prose.

Normalize around:

```txt
TARGET
FACTS
DOMAIN CONCEPTS
COMPONENTS / OWNERSHIP
ENTRYPOINTS
GOLDEN PATHS
CALL STACKS
DATA TRANSFORMATIONS
STATE READ / WRITE
I/O
SIDE EFFECTS
ERRORS / FAILURE PATHS
INVARIANTS
TEST EVIDENCE
RATIONALE + CONFIDENCE
GOTCHAS
FILES READ
CONTRADICTIONS
UNKNOWNS
```

Resolve overlap. Preserve contradictions and unknowns. Do not smooth gaps into a confident narrative.

Completion criterion: the teacher works from reconciled evidence rather than summarizing explorer essays independently.

## 10. Teach progressively

Follow `references/teaching-rubric.md`.

Start with the smallest complete mental model. Then deepen only as needed for the request.

A substantial one-shot explanation usually progresses through:

1. plain definition and mental model;
2. project vocabulary/domain model;
3. architecture and ownership;
4. one concrete golden path;
5. inputs, outputs, state, I/O, and side effects;
6. failure paths and edge cases;
7. tests worth reading;
8. surprising behavior and evidence-backed rationale;
9. change-oriented guidance when relevant.

For change-oriented requests, conclude with:

- invariants/contracts to preserve;
- likely files/modules involved;
- tests to run or read;
- downstream effects/blast radius;
- unresolved questions that should be answered before editing.

Reference specific files and symbols so the user can continue exploring. Avoid exhaustive inventories.

Completion criterion: after reading, the user should be able to draw the subsystem at a useful level, trace one important behavior, identify state/I/O/side effects, name the key domain concepts and invariants, and know where to look before making a change.

## Operating rules

- Read actual code. Never infer behavior from file names alone.
- Prefer execution paths over directory tours.
- Prefer project vocabulary over imposed architecture vocabulary.
- Distinguish architecture from filesystem layout.
- Show inputs, outputs, errors, state, I/O, and side effects where reachable.
- Surface runtime boundaries and representation changes.
- Keep unknowns and contradictions visible.
- Do not critique or redesign unless the user asks. Understanding comes first.
- Do not modify the target codebase while teaching it.
- Use diagrams when they reduce cognitive load. Build complex diagrams progressively rather than dropping one giant graph.
- Keep the final answer conversational and concrete. The investigation may be exhaustive; the explanation should be selective.
