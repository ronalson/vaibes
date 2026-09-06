---
name: show-me
description: Explain a topic with the smallest useful visual when a diagram, sketch, or focused artifact would clarify it.
---

# Show me

Help the user understand the current topic with the smallest visual that makes the key point clear. Keep supporting prose brief and place the visual beside the claim it explains. Do not use a visual as decoration or include unrelated calls, files, props, states, or boundaries.

Choose pseudocode for logic, a call tree for runtime flow, a component or file tree for ownership, a diff for change shape, and Mermaid for relationships or data flow. Use the examples in [visual-examples.md](references/visual-examples.md) when choosing or formatting a visual.

For a UI, layout, state comparison, or concept too dense for Mermaid, create one focused HTML file with real labels and data. Match the product's visual system when one exists, and support desktop and mobile. Preview it with the host's available file-preview mechanism. If no preview is available, deliver a clickable file link. This is a focused explanatory artifact, not an automatic reason to load or follow `html-doc`; use that separate workflow only when the user asks for an HTML document or report.
