# Typography Reference

Use this when implementing or reviewing text wrapping, font smoothing, dynamic numbers, headings, captions, or dense UI text.

## Text Wrapping

### `text-wrap: balance`

Use on headings and short title blocks where even line distribution matters.

```css
h1,
h2,
h3 {
  text-wrap: balance;
}
```

Tailwind:

```tsx
<h1 className="text-balance">...</h1>
```

Do not use `balance` on long paragraphs. Chromium applies balancing only to short blocks, and long text does not benefit.

### `text-wrap: pretty`

Use on short-to-medium body text, descriptions, captions, list items, and card copy to avoid orphaned final words.

```css
p,
li,
figcaption,
blockquote {
  text-wrap: pretty;
}
```

Tailwind:

```tsx
<p className="text-pretty">...</p>
```

Skip both `balance` and `pretty` for long prose, code blocks, logs, tables, and preformatted content.

## Font Smoothing

Apply font smoothing once at the root.

```css
html {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```

Tailwind:

```tsx
<html className="antialiased">
```

Do not apply smoothing inconsistently per component.

## Tabular Numbers

Use tabular numbers for values that update or align in columns.

```css
.counter {
  font-variant-numeric: tabular-nums;
}
```

Tailwind:

```tsx
<span className="tabular-nums">{count}</span>
```

Use for:

- Counters and timers
- Updating prices
- Numeric table columns
- Scoreboards and dashboards
- Animated number transitions

Do not force tabular numbers onto decorative large numbers, phone numbers, zip codes, or version strings unless alignment requires it.

Some fonts change numeral appearance when tabular numbers are enabled. Verify the result in the product's actual font.
