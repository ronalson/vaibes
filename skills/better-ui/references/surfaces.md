# Surfaces Reference

Use this when implementing or reviewing border radius, optical alignment, shadows, borders, image outlines, and hit areas.

## Concentric Border Radius

For nested rounded surfaces:

```text
outer radius = inner radius + padding
```

```css
/* Good: 12px inner + 8px padding = 20px outer */
.card {
  border-radius: 20px;
  padding: 8px;
}

.card-inner {
  border-radius: 12px;
}

/* Bad: identical radii on nested surfaces */
.card,
.card-inner {
  border-radius: 12px;
}
```

Tailwind example:

```tsx
<div className="rounded-2xl p-2">
  <div className="rounded-lg">...</div>
</div>
```

Strict concentric math matters most when surfaces are close together. If padding is larger than `24px`, treat the surfaces independently.

## Optical Alignment

Geometric centering is not always visually centered.

### Text and Icon Buttons

Use slightly less padding on the icon side:

```tsx
<button className="flex items-center gap-2 pl-4 pr-3.5">
  <span>Continue</span>
  <ArrowRightIcon />
</button>
```

Rule of thumb: icon-side padding is text-side padding minus `2px`.

### Play Buttons

Play triangles look left-heavy when geometrically centered. Shift the icon right by about `2px`.

```css
.play-button svg {
  margin-left: 2px;
}
```

### Asymmetric Icons

Prefer fixing the SVG viewBox or path so the component code does not need magic margins. Use `ml-px` or similar only as a fallback.

## Shadows vs. Borders

Use shadows when a border is acting as depth on cards, buttons, dropdowns, modals, and elevated containers. Keep borders for dividers, table lines, dense list separators, and form input outlines.

Light mode layered shadow:

```css
:root {
  --shadow-border:
    0 0 0 1px rgba(0, 0, 0, 0.06),
    0 1px 2px -1px rgba(0, 0, 0, 0.06),
    0 2px 4px 0 rgba(0, 0, 0, 0.04);
  --shadow-border-hover:
    0 0 0 1px rgba(0, 0, 0, 0.08),
    0 1px 2px -1px rgba(0, 0, 0, 0.08),
    0 2px 4px 0 rgba(0, 0, 0, 0.06);
}
```

Dark mode usually needs only a white ring:

```css
:root {
  --shadow-border-dark: 0 0 0 1px rgba(255, 255, 255, 0.08);
  --shadow-border-hover-dark: 0 0 0 1px rgba(255, 255, 255, 0.13);
}
```

Apply with a specific transition:

```css
.card {
  box-shadow: var(--shadow-border);
  transition-property: box-shadow;
  transition-duration: 150ms;
  transition-timing-function: var(--ease-out-ui);
}

.card:hover {
  box-shadow: var(--shadow-border-hover);
}
```

Do not replace accessibility-critical focus or input borders unless you provide an equally clear focus state.

## Image Outlines

Add a subtle inset outline to images so they hold up across mixed backgrounds.

```css
img {
  outline: 1px solid rgba(0, 0, 0, 0.1);
  outline-offset: -1px;
}

@media (prefers-color-scheme: dark) {
  img {
    outline-color: rgba(255, 255, 255, 0.1);
  }
}
```

Tailwind:

```tsx
<img className="outline outline-1 -outline-offset-1 outline-black/10 dark:outline-white/10" />
```

Use pure black in light mode and pure white in dark mode. Do not use tinted neutral scales such as slate, zinc, neutral, or accent colors for image outlines.

## Hit Areas

Interactive elements need at least `40x40px`, ideally `44x44px` where layout allows.

For small visible controls, extend the target with a pseudo-element:

```css
.checkbox {
  position: relative;
  width: 20px;
  height: 20px;
}

.checkbox::after {
  content: "";
  position: absolute;
  top: 50%;
  left: 50%;
  width: 40px;
  height: 40px;
  transform: translate(-50%, -50%);
}
```

Never let extended hit areas overlap another interactive element. Shrink the pseudo-element if needed.
