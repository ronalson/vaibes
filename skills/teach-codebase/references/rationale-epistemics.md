# Rationale Epistemics

Use this framework for claims about **why** code exists or was designed a particular way.

Code is strong evidence for current behavior. It is weak evidence for historical motivation.

## Confidence classes

### Direct

A source explicitly states the reason.

Examples: ADR decision, PR description, review comment, issue, commit message, code comment tied to the behavior.

Use confident language and cite the source.

### Supported

Multiple pieces of evidence strongly support the rationale, but no single source states it completely.

Explain the evidence chain and use language such as "the available evidence supports...".

### Inferred

The explanation is plausible and consistent with evidence, but intent is not recorded.

Use "appears to", "likely", or "suggests". State what makes the inference reasonable.

### Speculative

There is little evidence beyond technical plausibility.

Usually omit speculation from the lesson. If it helps orient the user, label it explicitly as speculation and offer competing possibilities.

### Unknown

The searched evidence does not establish a reason.

Say so. "We could not establish why this value is 30 seconds" is better than retrofitting intent.

## Rules

- Evidence before narrative.
- Never turn "this design has benefit X" into "it was designed this way because of X" without historical evidence.
- Surface contradictions between sources.
- Preserve hedges during synthesis and teaching.
- Distinguish current justification from original motivation.
- Tests can reveal protected edge cases, but usually do not prove why the behavior was originally introduced.
- A nearby commit or issue is not automatically causal. Establish the connection.
