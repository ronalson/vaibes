# Deepening

How to deepen a cluster of shallow modules safely, given its dependencies. Assumes the vocabulary in [SKILL.md](SKILL.md): **module**, **interface**, **seam**, **adapter**.

## Dependency categories

When assessing a candidate for deepening, classify its dependencies. The category suggests a testing and seam strategy; follow actual project boundaries, existing conventions, and the behavior being tested.

### 1. In-process

Pure computation, in-memory state, no I/O. It can often be deepened by merging modules and testing through the resulting interface directly. No adapter is usually needed.

### 2. Local-substitutable

Dependencies that may have local test stand-ins (PGLite for Postgres, in-memory filesystem). A stand-in can make integration-style testing practical, but its absence does not prevent deepening. Use it when it represents the relevant behavior; otherwise use the project's existing test environment or test a narrower seam. The seam can remain internal when callers do not need a port.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). A **port** at the seam and an injected transport adapter can help when the boundary varies or the test strategy benefits from substitution. Keep an established client or integration seam when that fits the project better. Tests may use an in-memory adapter, a local integration environment, or another representative setup; production may use HTTP, gRPC, or a queue adapter.

Recommendation shape, when the boundary and test strategy justify it: *"Define a port at the seam, implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."*

### 4. True external (Mock)

Third-party services (Stripe, Twilio, etc.) you don't control. An injected port with a mock or fake can isolate a true external boundary, especially when the project's conventions already use one. Prefer a provider sandbox, recorded fixture, or existing integration harness when that better exercises the risk; do not add an abstraction solely to obtain a mock.

## Seam discipline

- **Adapters should represent variation.** A port often needs more than one adapter, such as production and test. A single-adapter seam needs a clear boundary or testing reason so it does not become needless indirection.
- **Internal seams vs external seams.** A deep module can have internal seams (private to its implementation, used by its own tests) as well as the external seam at its interface. Don't expose internal seams through the interface just because tests use them.

## Testing strategy: replace, don't layer

- Remove old unit tests only when the behavior they cover was removed or the new interface tests make that coverage meaningfully redundant.
- Write new tests usually at the deepened module's interface. The **interface is the usual test surface**.
- Assert on observable outcomes through that interface when testing behavior. A focused internal test may assert a local invariant or pure calculation when no stable public behavior expresses it.
- Interface tests should survive internal refactors. Focused internal tests may change with the implementation they deliberately protect; keep them local and avoid exposing internal seams to callers just for tests.
