# Validation section

Every spec in this workflow carries a `## Validation` section that says how the work will be proven. `handoff` and `type-spec` both write it from this file, and `breakdown` checks it against this file before splitting a spec.

## Shape

Write these five H3 subsections, in this order, under `## Validation`:

```markdown
## Validation

### Feature map
- `verify-<app>`: `<feature-file>.md` → `<sub-feature-id>`, `<sub-feature-id>`

### Commands
- `<command>` (from `<file where the repo defines it>`)

### Fail-first
- `<command or feature-map journey>` fails before the change because <reason>, and passes after it.

### Review risks
- <area a reviewer should read closely, and why>

### Manual checks
- <step a person must do by hand, and the result to look for>
```

## What goes in each subsection

- **Feature map.** Look for `.claude/skills/verify-<app>/features/` in the target repo. List the feature files and sub-feature IDs (the backticked IDs under each file's `Sub-features` heading) that prove this change. Use only IDs that exist in the map. When the change adds behavior the map does not cover yet, list the existing IDs that still apply and name the feature file or sub-feature to add.
  When the repo has no `verify-<app>` skill, write `No verify-<app> skill in this repo. Run /create-verification-skill to add one.` in place of the list.
- **Commands.** The test, lint, type-check, build, or verify commands to run. Copy each from the repo (package scripts, Makefile, CI config, README, or the `verify-<app>` skill) and name the file it came from. Never invent a command. When the repo has none that fits, say so as an open question.
- **Fail-first.** At least one check that fails on the current code and passes once the work is done: a new or changed test, or a feature-map journey. State why it fails today.
- **Review risks.** At least one area where a mistake is likely or costly, such as a shared interface, data migration, auth path, or concurrency, with one line on why.
- **Manual checks.** Steps a person must perform that no command covers, with the result to look for. Write `None` when every check is automated.

## Complete or incomplete

A Validation section is complete when every item below holds. Anything else is incomplete, and the spec is not ready for `breakdown`.

1. The spec has a `## Validation` heading with all five H3 subsections, in the order above.
2. **Feature map** lists at least one feature file and sub-feature ID from an existing `verify-<app>` map, or states that the repo has no `verify-<app>` skill and points to `/create-verification-skill`.
3. **Commands** lists at least one command, and each names the repo file it came from.
4. **Fail-first** names at least one check and says why it fails before the change.
5. **Review risks** lists at least one area.
6. **Manual checks** lists at least one step, or says `None`.
7. No subsection contains template placeholders (`<...>`), `TODO`, or `TBD`.

When a spec fails a check, name the failed item numbers and what is missing. Fix the spec, or ask the user for what only they know. Do not split or implement a spec with an incomplete Validation section.
