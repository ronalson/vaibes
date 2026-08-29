# Architecture vocabulary

Use these terms exactly. They match the sibling `codebase-design` skill. Do not substitute component, service, API, or boundary.

**Module**: anything with an interface and an implementation. Scale-agnostic: a function, class, package, or tier-spanning slice. Avoid: unit, component, service.

**Interface**: everything a caller must know to use the module correctly. Type signature plus invariants, ordering constraints, error modes, required configuration, and performance characteristics. Avoid: API, signature (too narrow).

**Implementation**: what is inside a module. Distinct from adapter.

**Depth**: leverage at the interface. A module is deep when a large amount of behaviour sits behind a small interface. Shallow when the interface is nearly as complex as the implementation.

**Seam**: the location at which a module's interface lives. Where to put the seam is its own design decision.

**Adapter**: a concrete thing that satisfies an interface at a seam. Role, not substance.

**Leverage**: what callers get from depth. More capability per unit of interface they learn.

**Locality**: what maintainers get from depth. Change, bugs, knowledge, and verification concentrate in one place.

## Checks to run while teaching

- Deletion test. If we deleted this module, does complexity vanish or explode across callers?
- One adapter means a hypothetical seam. Two adapters means a real one.
- The interface is the test surface. If you have to test past it, the module is probably the wrong shape.
- Name what must not leak across the seam: framework types, persistence DTOs, clock, randomness, telemetry.
