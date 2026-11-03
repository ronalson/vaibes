---
name: breakdown
description: Split a settled plan into vertical phases that agents can execute in order or in parallel, each reviewable on its own.
---

# Breakdown

Turn a plan into phases. A phase is a block of implementation that lands working behavior and can be reviewed without reading the phases around it. Sequence the phases by what they actually depend on, not by layer, and run the independent ones at the same time.

Use this once the plan is settled. Breaking down a plan the user has not agreed to produces phases for the wrong work.

## Before you start

Breakdown works on a spec in `context/specs/`, written with `handoff` or `type-spec`. When no spec exists, write one with either skill first.

Read the spec's `## Validation` section and check it against "Complete or incomplete" in [../handoff/references/validation.md](../handoff/references/validation.md), the shared definition in the `handoff` skill. This skill needs `handoff` installed alongside it.

If Validation is missing or any item fails, stop. Do not write phases. Tell the user which item numbers failed and what is missing, for example: "Validation item 3 fails: `pnpm test` does not name the file it came from." Fix the spec, or ask the user for what only they know, then check again.

## Glossary

**Phase**: one block of implementation that lands as a reviewable unit. Sized so a reviewer can hold all of it at once.

**Vertical slice**: a phase that cuts through every layer it needs to make behavior observable — schema, logic, and surface together. The opposite is a **horizontal layer**: all the types, then all the services, then all the endpoints.

**Edge**: phase B has an edge from phase A when B cannot start until A exists. Real edges come from one phase needing another's interface, schema, or file. A shared topic is not an edge.

**Wave**: the set of phases with no edges between them, dispatched together. Waves are the execution plan; phases are the work.

**Seam** (see `codebase-design`): where behavior can change without editing that place. Seams are where phases divide, because a phase that owns one side of a seam can be written against the interface rather than against the other side's code.

**Contract phase**: a small first phase that lands only the interface at a seam — types, signatures, a stub that compiles — so both sides can then proceed in parallel. Use it when two phases would otherwise queue behind each other.

**Review gate**: the acceptance criteria and the spec's Validation items that decide whether a phase is done. A phase without one is not reviewable.

## Tests for a phase

Apply these to each candidate phase. A phase that fails one is usually two phases, or half of one.

- **The demo test.** Can you show it working when the phase lands? If the answer is "not until phase 4", it is a horizontal layer.
- **The stop test.** If everything stops here, is the tree green and the system coherent? Every phase leaves main working. No phase depends on a later phase to un-break it.
- **The review test.** Can one reviewer hold the whole phase at once? If reviewing it means paging in three other phases, the seam is in the wrong place.
- **The revert test.** Can this phase be reverted alone? If reverting it breaks a sibling, they are entangled and belong together.

## What can run in parallel

Two phases run in parallel only when both hold:

- **No edge between them.** Neither needs an interface, type, schema, or migration the other has not landed yet.
- **Disjoint files.** Two agents editing the same file conflict, and reconciling that costs more than running them in sequence. Check the `Owns:` lists, not the topics.

Each parallel phase runs in its own worktree and merges back afterward, so its `Owns:` list must name every file it creates or edits. A file missing from the list is a merge conflict nobody planned for.

When two phases want the same seam, land a contract phase first and fan out after it. When they want the same file, sequence them.

Keep fan-out to what the work needs. Three agents on three genuinely independent slices is worth it; six agents on six slices that all touch the router is not.

## Output

Append a `## Phases` section to the spec, after `## Validation`. `delegate` reads the phases from there, so keep the field names and order below exactly, with one phase per H3.

Open with the wave plan, then the phases. Each phase includes: Wave, Depends on, Agent, Owns, Lands, Acceptance, Gate.

```markdown
## Phases

Wave 1: phase 1
Wave 2: phases 2, 3 in parallel
Wave 3: phase 4

### Phase 2 — <short-name>
- Wave: 2
- Depends on: phase 1
- Agent: worker
- Owns: `src/cart/add.ts`, `src/cart/add.test.ts`
- Lands: the behavior that is observable once this phase is in
- Acceptance: testable conditions, not a restatement of the work
- Gate:
  - Feature map: `cart.md` → `cart-add-item`
  - Commands: `pnpm test` (from `package.json`)
  - Fail-first: `add.test.ts` "adds a second item" fails before the change because quantities overwrite
  - Review risks: shared cart total calculation
  - Manual checks: None
```

Field rules:

- **Wave.** The wave number from the plan. Phases that share a wave run in parallel; a wave with one phase runs alone.
- **Depends on.** Phase numbers, or `nothing`.
- **Agent.** Always `worker`.
- **Owns.** Every file the phase creates or edits, as exact backticked paths. Phases in the same wave must not share a path.
- **Gate.** Copy items from the spec's Validation section; do not invent checks. Use the five subsection names as labels, list the items from each that prove this phase, and write `None` where no item applies. Every gate needs at least one Commands entry or Feature map ID. If a phase needs a check the spec lacks, add it to Validation first and recheck completeness.

Give every phase a `Lands:` line stating observable behavior. If you cannot write one, the phase is a layer and needs reslicing.

Number phases in dependency order. Keep phase names short, since `delegate` uses them to name branches. Put the review gate in the phase itself so a reviewer never has to reconstruct it.

Every Validation item belongs to at least one gate. A fail-first check or manual check that no phase claims is never run.

Hand the user the spec path when the breakdown is written. Execute with the `delegate` skill.

## Rejected framings

- **Phases as layers.** Types, then services, then endpoints. Nothing is demonstrable until the last one, and every review is provisional.
- **Phases as commits or file counts.** Neither is a unit of behavior. A phase is what a reviewer can judge, which sometimes means one file and sometimes eight.
- **Phases as a task checklist.** A checklist tracks work; a phase has a review gate that can fail.
- **Maximum parallelism.** Wall-clock time is not the constraint. Conflicting edits and unreviewable diffs are.
