# Mental model

Living map of this codebase for humans and agents. Glossary stays free of implementation details.

## Language

**Term**:
What it is, in one or two sentences.
_Avoid_: rejected synonym

## Contexts

- Name: what this context is for
- Relationships: who talks to whom, and with which events or types

## State

- Owner: UI, URL, cache, process memory, persistence, queue, or external system
- State: what it owns and how it changes

## Seams

- Module:
- Interface:
- Adapters:
- Must not leak:

## Critical traces

### Trace name

Trigger:

```txt
trigger -> ... -> effect
```

Errors:
Effects:

## Gotchas

Non-obvious rules a newcomer would get wrong.

## Open questions
