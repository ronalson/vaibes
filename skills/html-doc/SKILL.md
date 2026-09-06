---
name: html-doc
description: Create a polished, single-file HTML document when the user requests an HTML report, document, or .html deliverable.
---

# HTML document

Create exactly one `.html` file at the requested location, or choose a descriptive workspace filename. Deliver the file link, not only source code. This skill is for documents, reports, findings, comparisons, and explanatory visualizations. Do not use it for websites, web apps, reusable UI components, HTML snippets, DOCX, PDFs, or slide decks.

The document loads Tailwind from a CDN, so full styling requires network access. It is not fully self-contained or guaranteed to work offline. Use Mermaid's CDN only when a diagram materially clarifies the content.

## Build the requested document

1. Identify the purpose, reader, language, source material, and requested style. Preserve supplied facts and citations. Do not invent findings or sources.
2. Choose a structure that fits the artifact. Use a visual only when it communicates better than prose.
3. Start from [html-document-scaffold.html](assets/html-document-scaffold.html). Keep its theme toggle, accessible behavior, semantic status colors, and print treatment. Set `lang` and replace the placeholder content.
4. Use semantic HTML, a logical heading hierarchy, real tables for tabular data, readable narrow-screen layout, and useful alt text. Keep external links safe with `target="_blank"` and `rel="noopener noreferrer"`.
5. Keep the page static apart from the required theme toggle. Do not load scripts other than Tailwind and, when needed, Mermaid. Embed images as data URLs when portability matters; otherwise use HTTPS sources, never machine-local paths. Give meaningful inline SVGs a `<title>` and `<desc>`.

When the user asks for variants, render the requested alternatives in the same file and label them `A`, `B`, and so on. Place them side by side on wide screens and stack them on narrow screens.

Use the grayscale visual system and status rules in [visual-system.md](references/visual-system.md). Read [mermaid.md](references/mermaid.md) only when the document needs a Mermaid diagram. Use [acceptance-checklist.md](references/acceptance-checklist.md) before delivery.

## Verify and finish

Render the document at desktop and mobile widths. Verify that the theme initializes from `localStorage`, the toggle changes its label and icons, the selection persists, and print uses the light palette. Check overflow, clipping, links, diagrams, and browser console errors. Record any blocked CDN dependency or unavailable browser check accurately. Finish by linking the single generated file.
