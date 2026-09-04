# Investigation contract

Read the implementation behind every material claim. Follow concrete symbols, callers, callees, types, tests, and boundaries. A filename, folder, class name, or framework convention is a lead, not evidence of runtime behavior.

Record `file:symbol` for each material claim. If a call leaves the searchable codebase, mark the boundary and what remains unknown.

Use an evidence label that distinguishes facts from interpretation. Direct evidence is opened code, tests, configuration, documentation, or history. A conclusion that combines those sources is supported or inferred. Do not present a convention or a filename as direct evidence.

For a relevant behavior, trace the trigger, input, validation, representations, decisions, state reads and writes, I/O, effects, output, expected errors, error handling, and relevant tests. Include retries, cancellation, timeouts, transactions, idempotency, and authorization when they affect the path.

Do not stop at generic verbs such as "handles" or "processes." Name the next code-proven mechanism.

When a path crosses a seam, record the representation on both sides. Note whether the path reads or writes UI state, URL state, cache state, process memory, persistent storage, queue state, or external-system state.

Identify behavioral ownership, not folder shape. Do not assume that a folder is a module, a package is a domain, or a class is an abstraction.

Use project-native terms. Surface overloaded terms, special IDs, status transitions, encoded invariants, and conflicts between code and documentation.

Read tests around public seams. Treat assertions as strong evidence of protected behavior, not proof of product requirements or historical intent. Reconcile tests with implementation and docs.

Record contradictions directly. For example, a README may describe a synchronous operation while the implementation queues a job. A contradiction is a lesson, not something to smooth over.

Keep the investigation read-only. Return evidence, not polished teaching prose.

Stop when the assigned slice reaches the output or final effect without an invented hop, or when it reaches an explicit unavailable boundary.
