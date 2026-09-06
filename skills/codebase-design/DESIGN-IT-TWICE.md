# Design It Twice

When a material interface choice remains unresolved, explore alternatives for the chosen deepening candidate. Based on "Design It Twice" (Ousterhout), a first idea can miss a better shape.

Uses the vocabulary in [SKILL.md](SKILL.md): **module**, **interface**, **seam**, **adapter**, **leverage**.

## Process

### 1. Frame the problem space

Frame the problem space for the chosen candidate:

- The constraints any new interface would need to satisfy
- The dependencies it would rely on, and which category they fall into (see [DEEPENING.md](DEEPENING.md))
- A rough illustrative code sketch to ground the constraints, not a proposal, just a way to make the constraints concrete

Share this framing when it helps the decision.

### 2. Develop alternatives

Develop two or more materially different interfaces. Use parallel sub-agents only when the alternatives can be explored independently and that work will improve the decision. A single agent can develop and compare alternatives when delegation would add overhead.

For each alternative, use a technical brief with relevant file paths, coupling details, dependency category from [DEEPENING.md](DEEPENING.md), and what sits behind the seam. Vary the design constraint:

- **Minimal interface:** aim for 1–3 entry points and maximize leverage per entry point.
- **Flexible interface:** support multiple use cases and extension.
- **Common caller:** make the default case trivial.
- **Ports and adapters:** when applicable, design for cross-seam dependencies.

Use the project vocabulary and [SKILL.md](SKILL.md) definitions where they help describe the architecture.

Each alternative should show:

1. Interface (types, methods, params, plus invariants, ordering, error modes)
2. Usage example showing how callers use it
3. What the implementation hides behind the seam
4. Dependency strategy and adapters (see [DEEPENING.md](DEEPENING.md))
5. Trade-offs: where leverage is high, where it's thin

### 3. Present and compare

Present designs sequentially so the user can absorb each one, then compare them in prose. Contrast by **depth** (leverage at the interface), **locality** (where change concentrates), and **seam placement**.

After comparing, give your own recommendation: which design you think is strongest and why. If elements from different designs would combine well, propose a hybrid. Be opinionated: the user wants a strong read, not a menu.
