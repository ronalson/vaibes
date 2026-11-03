# Review report

Read this when writing the report. Save it as `<run folder>/review-report.md`. Every finding the reviewer returned appears once, confirmed or rejected; drop nothing silently.

```markdown
# Review: <base>..<head>

- Spec: `<repo>/context/specs/<spec>.md`
- Reviewer: <grok-4.7 or glm-5.3>, findings in `<run folder>/reviewer-findings.md`
- Scouts: <none, or each question and its answer file>

## Verdict

<merge | fix>. <One sentence on why.>

## Findings

| # | Severity | Location | Finding | Status | Reason |
|---|---|---|---|---|---|
| 1 | high | `path:line` | <the defect, in one line> | confirmed | <what in the code shows it is real> |
| 2 | low | `path:line` | <...> | rejected | <why it does not hold> |

Write `No findings.` when the reviewer returned none and you found none.
Add findings from your own checks or reruns with `self` after the number, such as `3 (self)`.

## Validation coverage

| Item | Evidence | Status |
|---|---|---|
| Feature map: `<sub-feature-id>` | `<artifact path>` | covered |
| Commands: `<command>` | `<result file>`, exit 0 | covered |
| Fail-first: `<check>` | fails before at `<path>`, passes after at `<path>` | covered |
| Review risks: <area> | finding <#>, or checked at `path:line` | covered |
| Manual checks: <step> | none | missing |
| Phase <N> Gate: <item> | rerun by review, `<path>`, exit 0 | covered |

## To fix

<Only for a fix verdict: each confirmed finding by number, and each missing evidence item.>
```

Fill in every `<...>`. An item is covered only when the evidence is in the run folder and shows the result; a claim in a result file without output is missing.
