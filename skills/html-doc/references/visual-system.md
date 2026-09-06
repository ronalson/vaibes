# Visual system

Use a grayscale palette unless the user supplies another style: `stone-50` page background, white surfaces, `slate-900` primary text, `slate-600` secondary text, `slate-200` borders, and `slate-950` strong emphasis. The scaffold maps these values for dark mode.

Avoid landing-page conventions such as hero sections, decorative chrome, marketing language, and excessive card grids. Keep the document information-dense without cramped spacing. Use serif headings only when they suit the subject. Use `text-xs uppercase tracking-wider` for diagram labels, not ordinary interface text.

Reserve color for meaning:

- Red indicates danger, failure, error, or destructive consequences.
- Green indicates success, completion, approval, or passing results.
- Amber indicates warning, caution, risk, or required attention.

Use status color sparingly in small labels, icons, borders, badges, or muted callouts. Pair it with a text label and, when useful, an icon or border distinction. Do not use saturated color as decoration or as the only way to communicate a distinction.

Use semantic HTML and CSS for comparisons, matrices, callouts, and annotated text. Use Mermaid for flows and relationships. Use inline SVG for spatial or editorial visuals that need precise composition. Choose the technique that best communicates the content; do not mix techniques merely for variety. Aim for diagrams around 320px tall when practical, and keep wide tables and diagrams usable on narrow screens. Prefer `currentColor` or theme variables for custom SVGs.

When a document adds a Tailwind color utility beyond the grayscale system, add its dark-mode override. Preserve readable contrast in both themes. Give meaningful inline SVGs a `<title>` and `<desc>`.

When the user requests variants, render real alternatives rather than hypothetical descriptions. Label them `A`, `B`, `C`, and so on. Render representative sections for style variants, full variants when practical, and the relevant sections for content or process options. Place variants side by side on wide screens and stack them on narrow screens.
