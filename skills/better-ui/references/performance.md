# Performance Reference

Use this when implementing or reviewing animation performance, transition properties, `will-change`, Motion/Framer Motion usage, CSS variables, and reduced motion.

## Specify Transition Properties

Never use `transition: all` for UI polish work. It causes unexpected animation, broad style watching, and weaker browser optimization.

```css
/* Good */
.button {
  transition-property: transform, background-color;
  transition-duration: 150ms;
  transition-timing-function: var(--ease-out-ui);
}

/* Bad */
.button {
  transition: all 150ms ease-out;
}
```

Tailwind:

```tsx
// Good
<button className="transition-[transform,background-color] duration-150">

// Good for transform-only changes
<button className="transition-transform duration-150">

// Bad: maps broadly
<button className="transition duration-150">
```

## Animate Compositor-Friendly Properties

Prefer:

- `transform`
- `opacity`
- `filter` for restrained blur/brightness
- `clip-path` for reveals when tested

Avoid animating unless necessary:

- `height`
- `width`
- `top`
- `left`
- `padding`
- `margin`
- `border`
- `background` on large elements

Animating layout properties triggers layout and paint. Transform and opacity can usually run on the compositor.

## `will-change`

Use `will-change` only when you observe first-frame stutter. Each promoted layer costs memory.

```css
/* Good when needed */
.animated-card {
  will-change: transform;
}

.fading-panel {
  will-change: opacity, transform;
}

/* Bad */
.thing {
  will-change: all;
}
```

Use only compositor-friendly properties: `transform`, `opacity`, `filter`, and sometimes `clip-path`.

## CSS Variables During Gestures

CSS variables inherit. Updating a variable on a parent can recalculate styles for all descendants.

```ts
// Bad in dense trees
element.style.setProperty("--swipe-amount", `${distance}px`);

// Better for high-frequency gesture updates
element.style.transform = `translateY(${distance}px)`;
```

For drag/swipe loops, write the final transform to the animated element directly when performance matters.

## Motion and Framer Motion Caveats

Motion library shorthand props such as `x`, `y`, and `scale` are convenient, but they are JavaScript-driven. Under load, CSS transforms and CSS animations can remain smoother.

```tsx
// Convenient, but JS-driven
<motion.div animate={{ x: 100 }} />

// Prefer for performance-sensitive predetermined movement
<motion.div animate={{ transform: "translateX(100px)" }} />
```

Use Motion for gestures, layout transitions, spring interruption, and stateful choreography. Use CSS for simple predetermined transitions and animations.

For utilitarian icon swaps or state transitions, prefer springs with no bounce:

```tsx
transition={{ type: "spring", duration: 0.3, bounce: 0 }}
```

Use bounce only when the component's personality supports it.

## WAAPI

Use the Web Animations API when you need JavaScript control with browser-native animation behavior.

```ts
element.animate(
  [
    { clipPath: "inset(0 0 100% 0)" },
    { clipPath: "inset(0 0 0 0)" },
  ],
  {
    duration: 1000,
    fill: "forwards",
    easing: "cubic-bezier(0.77, 0, 0.175, 1)",
  },
);
```

## Reduced Motion

Reduced motion means fewer and gentler animations, not necessarily zero visual feedback.

```css
@media (prefers-reduced-motion: reduce) {
  .panel {
    transform: none;
    transition-property: opacity;
    transition-duration: 120ms;
  }
}
```

Remove large movement, parallax, bounce, and spatial travel. Keep opacity and color transitions where they make state easier to understand.

## Touch Hover

Gate hover motion so touch devices do not get sticky hover effects.

```css
@media (hover: hover) and (pointer: fine) {
  .card:hover {
    transform: translateY(-2px);
  }
}
```

## Final Checks

- No `transition: all`.
- No `will-change: all`.
- No hover-only motion on touch devices.
- No large transform motion in reduced-motion mode.
- No layout-property animation in hot paths.
- No expensive blur above what is needed; keep blur subtle, usually `2-4px` and well below `20px`.
