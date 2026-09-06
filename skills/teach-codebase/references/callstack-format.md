# Call stack format

Use this format when a Trace or primary Onboard path needs a hop table. Use project types. If the code uses strings, say strings.

```txt
trigger
  -> raw input
  -> parse or validate
  -> canonical input
  -> module interface
  -> adapter or I/O
  -> result or expected error
  -> projection
  -> observable result
```

| Hop | In | Out | Errors | Effects | Evidence |
| --- | --- | --- | --- | --- | --- |
| `file:symbol` | input type | output type | expected error | state, I/O, or external effect | `file:symbol` |

Every material hop names `file:symbol` or **open question**. Do not invent branded types or a missing step. Add a row only when it changes the input, output, error handling, state, I/O, or observable result. A framework callback with no relevant behavior can remain inside the previous hop's explanation.

When a value changes across a seam, add a representation line. For example:

```txt
unknown JSON -> request DTO -> command -> domain value -> persistence DTO
```

Name state reads and writes on the path. Use the relevant owner: UI, URL, cache, process memory, persistence, queue, or external system.

Name invariants at the decision hop that enforces them. Link a relevant test to the hop that it protects. If a test and the implementation disagree, make the disagreement an open question.

Sketch these as separate short stacks when they apply:

- Failure: error type, translation, and caller-visible result.
- Retry, cancellation, timeout, transaction, or idempotency: what can replay and what cannot.
- Observability: spans, metrics, and log fields.
- Authorization: checks, location, and assumptions after the seam.

Do not combine these flows with the primary path when that hides the normal behavior. A separate failure stack is easier to read than error arrows on every row.

Stop when you can walk from trigger to the final code-proven effect without a hand-waved hop. Otherwise, record the gap.
