---
name: tdd
description: Test-driven development. Use when the user explicitly asks to build or fix something test-first, or asks for a red-green-refactor workflow.
---

# Test-Driven Development

TDD uses a red → green → refactor loop to produce tests worth keeping. Work in small vertical slices and use the project's existing test conventions.

When exploring the codebase, read `CONTEXT.md` (if it exists) so test names and interface vocabulary match the project's domain language, and respect ADRs in the area you're touching.

## What a good test is

Tests should usually verify behavior through public interfaces, not implementation details. A good test reads like a specification: "user can checkout with valid cart" tells you exactly what capability exists and survives refactors because it does not depend on internal structure.

See [TESTS.md](TESTS.md) for examples and [MOCKING.md](MOCKING.md) for mocking guidelines.

## Seams: where tests go

A **seam** is a boundary where a test can observe behavior without depending on implementation details. Prefer a public interface. A justified internal test can protect a local invariant or pure calculation when no stable public behavior expresses it.

Infer the appropriate seam from the request, existing tests, and project conventions. Ask only when a material interface or scope choice remains unresolved.

When the interface shape is itself in question, use `codebase-design` as a design reference before choosing the seam.

## Anti-patterns

- **Implementation-coupled**: unnecessarily mocks internal collaborators, tests private methods, or verifies through a side channel (querying the database instead of using the interface). A focused internal test or test double can be justified for a local invariant, pure calculation, or real system boundary. The tell: the test breaks when you refactor but behavior hasn't changed and it protects no such focused concern.
- **Tautological**: the assertion recomputes the expected value the way the code does (`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a constant asserted equal to itself), so it passes by construction and can never disagree with the code. Expected values must come from an independent source of truth: a known-good literal, a worked example, the spec.
- **Horizontal slicing**: writing all tests first, then all implementation. Bulk tests verify _imagined_ behavior: you test the _shape_ of things rather than user-facing behavior, the tests go insensitive to real changes, and you commit to test structure before understanding the implementation. Work in **vertical slices** instead: one test → one implementation → repeat, each test a **tracer bullet** that responds to what the last cycle taught you.

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code to pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per cycle.
- **Refactor after green.** Once the test passes, improve the design without changing behavior, then rerun the affected tests.
