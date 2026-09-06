---
name: codebase-design
description: Design or improve module interfaces, seams, and testability.
---

# Codebase Design

Use deep-module ideas when designing or restructuring code would benefit from them: a lot of behavior behind a small interface, placed at a useful seam, and testable through that interface. The aim is leverage for callers, locality for maintainers, and testability.

## Glossary

Use these definitions when they clarify the design. Keep established project terms such as component, service, API, or boundary when they are more precise in that codebase.

**Module**: anything with an interface and an implementation. It can be a function, class, package, or tier-spanning slice.

**Interface**: everything a caller must know to use the module correctly: the type signature, invariants, ordering constraints, error modes, required configuration, and performance characteristics. An API may be part of an interface.

**Implementation**: what's inside a module, its body of code. Distinct from **Adapter**: a thing can be a small adapter with a large implementation (a Postgres repo) or a large adapter with a small implementation (an in-memory fake). Reach for "adapter" when the seam is the topic; "implementation" otherwise.

**Depth**: leverage at the interface. The amount of behaviour a caller (or test) can exercise per unit of interface they have to learn. A module is **deep** when a large amount of behaviour sits behind a small interface, **shallow** when the interface is nearly as complex as the implementation.

**Seam** _(Michael Feathers)_: a place where behavior can change without editing that place, often where a module interface lives. Its placement is a design decision distinct from what goes behind it.

**Adapter**: a concrete thing that satisfies an interface at a seam. Describes *role* (what slot it fills), not substance (what's inside).

**Leverage**: what callers get from depth. More capability per unit of interface they learn. One implementation pays back across N call sites and M tests.

**Locality**: what maintainers get from depth. Change, bugs, knowledge, and verification concentrate in one place rather than spreading across callers. Fix once, fixed everywhere.

## Deep vs shallow

**Deep module** = small interface + lots of implementation:

```
┌─────────────────────┐
│   Small Interface   │  ← Few methods, simple params
├─────────────────────┤
│                     │
│  Deep Implementation│  ← Complex logic hidden
│                     │
└─────────────────────┘
```

**Shallow module** = large interface + little implementation (avoid):

```
┌─────────────────────────────────┐
│       Large Interface           │  ← Many methods, complex params
├─────────────────────────────────┤
│  Thin Implementation            │  ← Just passes through
└─────────────────────────────────┘
```

When designing an interface, ask:

- Can I reduce the number of methods?
- Can I simplify the parameters?
- Can I hide more complexity inside?

## Principles

- **Depth is usually visible at the interface.** A deep module can be internally composed of small, mockable, swappable parts that are not part of its external interface. It can also have internal seams used by its own tests.
- **The deletion test.** Imagine deleting the module. If complexity vanishes, it may be a pass-through. If complexity reappears across callers, it may be earning its keep.
- **The interface is usually the test surface.** Callers and most tests should cross the same seam. A focused internal test can be useful for a local invariant or pure calculation.
- **Adapters should represent variation.** A seam with one adapter can be justified, but avoid adding it when no variation, boundary, or test need exists.

## Designing for testability

Good interfaces make testing natural:

1. **Consider injected dependencies at real boundaries.**

   ```typescript
   // Testable
   function processOrder(order, paymentGateway) {}

   // Hard to test
   function processOrder(order) {
     const gateway = new StripeGateway();
   }
   ```

2. **Prefer explicit results when they make behavior easier to test.**

   ```typescript
   // Testable
   function calculateDiscount(cart): Discount {}

   // Hard to test
   function applyDiscount(cart): void {
     cart.total -= discount;
   }
   ```

3. **Small surface area.** Fewer methods = fewer tests needed. Fewer params = simpler test setup.

## Relationships

- A **Module** has an interface that it presents to callers and tests.
- **Depth** is a property of a **Module**, measured against its **Interface**.
- A **Seam** is where a **Module**'s **Interface** lives.
- An **Adapter** sits at a **Seam** and satisfies the **Interface**.
- **Depth** produces **Leverage** for callers and **Locality** for maintainers.

## Rejected framings

- **Depth as ratio of implementation-lines to interface-lines** (Ousterhout): rewards padding the implementation. We use depth-as-leverage instead.
- **"Interface" as the TypeScript `interface` keyword or a class's public methods**: too narrow: interface here includes every fact a caller must know.
- **"Boundary"**: use it when the project means a bounded context, process, or ownership boundary. Use **seam** when discussing where behavior can vary.

## Going deeper

- **Deepening a cluster given its dependencies**, see [DEEPENING.md](DEEPENING.md): dependency categories, seam discipline, and replace-don't-layer testing.
- **Exploring alternative interfaces**, see [DESIGN-IT-TWICE.md](DESIGN-IT-TWICE.md): compare alternatives when a material design choice remains unresolved.
