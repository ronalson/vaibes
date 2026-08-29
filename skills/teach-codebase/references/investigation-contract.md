# Investigation Contract

Use this contract for every codebase exploration slice.

## Evidence posture

Read the implementation. Follow symbols, callers, callees, types, tests, and concrete boundaries. A filename, directory name, class name, or framework convention is a lead, not evidence of runtime behavior.

Record file paths and symbols for material claims. Line numbers are useful when stable and available, but symbols are usually more durable.

If a call crosses outside the searchable codebase, stop at the boundary and mark what is unknown.

## Trace contract

For every important behavior, capture as many of these as are reachable:

1. trigger;
2. entrypoint;
3. input shape/type;
4. parsing/validation;
5. canonical application/domain representation;
6. call chain;
7. important decisions and invariants;
8. state read;
9. state written;
10. I/O;
11. side effects;
12. output/result;
13. expected errors;
14. error translation/handling;
15. async/process/runtime boundaries;
16. retry, cancellation, timeout, transaction, idempotency, and authorization behavior;
17. relevant tests;
18. unresolved or untraced steps.

Do not stop at generic verbs such as "processes", "handles", "calls the backend", or "updates state". Name the mechanism and the next meaningful boundary.

## Architecture contract

Identify behavioral ownership, not just folders.

For each relevant component/module, determine:

- what behavior or invariant it owns;
- its public seam/interface;
- what calls it;
- what it calls;
- what representations cross its boundaries;
- what complexity it hides;
- whether the boundary is local, persistence, network, runtime, framework, or external-service related.

Do not assume `folder = module`, `package = domain`, or `class = abstraction`.

## Domain contract

Capture project-native terms and relationships. Flag:

- same concept with multiple names;
- same name used for multiple concepts;
- state/status transitions;
- identifiers with special meaning;
- encoded invariants;
- docs that contradict code.

Do not rename the project's concepts merely to fit a preferred architecture vocabulary.

## Tests contract

Treat tests as executable evidence of behavior the codebase protects. Find representative tests for:

- happy path;
- failures;
- edge cases;
- invariants;
- state transitions;
- external boundaries;
- retry/idempotency/runtime behavior.

Record the best tests for a newcomer to read, not every test file.

## Investigator output

Return evidence, not a polished tutorial.

Use this structure when practical:

```txt
ANGLE

FACTS
- claim — file:symbol

COMPONENTS / OWNERSHIP
- component — responsibility — seam

FLOW
1. trigger — file:symbol
2. ...

INPUT / OUTPUT
- ...

STATE
- reads: ...
- writes: ...

I/O
- ...

SIDE EFFECTS
- ...

ERRORS / FAILURE PATHS
- ...

INVARIANTS
- ...

TEST EVIDENCE
- test — behavior protected

SURPRISING / NON-OBVIOUS
- ...

CONTRADICTIONS
- ...

UNKNOWNS
- ...

FILES READ
- ...
```

## Stop condition

Stop when the assigned slice can be explained from trigger/input to output/effect without hand-waving a meaningful step, or when the trace reaches a boundary outside available evidence.
