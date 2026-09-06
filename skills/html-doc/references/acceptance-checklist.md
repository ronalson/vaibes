# Acceptance checklist

Before delivery, confirm that:

- Exactly one `.html` file exists and its title, language, content, and visual treatment match the request.
- The document has semantic headings and tables, useful image alt text, accessible links, and `<title>` and `<desc>` for meaningful inline SVGs.
- Desktop and mobile layouts have no horizontal page overflow, clipped visuals, broken links, or unreadable wide tables and diagrams.
- The saved theme initializes before Tailwind, defaults to light when no preference is saved, toggles correctly, updates its accessible label and icon, persists through `localStorage`, and prints with the light palette.
- Red, green, and amber indicate only danger, success, and warning. Every status also has a text or non-color cue.
- Mermaid renders without errors when used. Browser console errors are resolved.
- The final response links to the generated HTML file.

If browser rendering or CDN loading is unavailable, record the unavailable check and its dependency. Do not report an unrendered document as visually verified.
