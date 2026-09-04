# Rationale epistemics

Code strongly supports claims about current behavior. It weakly supports claims about historical motivation.

## Confidence classes

### Direct

A source states the reason. Cite the ADR, issue, PR, commit, review comment, or related code comment.

### Supported

Several sources support the rationale, but none states all of it. Explain the evidence chain.

### Inferred

The explanation fits the evidence, but no source records intent. Say "appears to" or "likely," and name the evidence.

### Speculative

Technical plausibility is the main evidence. Usually omit it. If it helps orientation, label it as speculation and give alternatives.

### Unknown

The searched evidence does not establish the reason. Say so.

Never turn "this design has benefit X" into "it was designed for benefit X" without historical evidence. Preserve contradictions and hedges. Tests can show protected behavior, but rarely establish why it was introduced.
