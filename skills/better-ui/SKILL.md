---
name: better-ui
description: Improve frontend UI polish through practical design-engineering review and implementation. Use this whenever the user asks to make an interface feel better, polish UI, refine animations, improve hover/press states, review frontend visuals, fix "feels off" details, tune typography, shadows, border radius, popovers, tooltips, drawers, toasts, or micro-interactions. This skill is for concrete UI craft changes, not broad product redesigns or marketing-only art direction.
---

# Better UI

Make interfaces feel intentional by tightening the small details that compound: motion, surfaces, typography, input feedback, and performance. Prefer concrete code changes over taste commentary.

## Working Loop

1. Inspect the existing UI stack, design system, component library, and nearby patterns before changing anything.
2. Identify the interaction frequency and purpose before adding motion.
3. Make the smallest polish changes that improve feel while matching the product's tone.
4. Load the focused reference file when implementation details matter:
   - [references/motion.md](references/motion.md) for transitions, easing, enter/exit, icon swaps, popovers, tooltips, gestures, and animation debugging.
   - [references/surfaces.md](references/surfaces.md) for radius, optical alignment, shadows, image outlines, and hit areas.
   - [references/typography.md](references/typography.md) for text wrapping, font smoothing, and tabular numbers.
   - [references/performance.md](references/performance.md) for transition specificity, compositor-friendly animation, `will-change`, CSS variables, Motion caveats, and reduced motion.
5. Verify visually when possible: desktop and mobile viewport, hover/focus/active states, reduced motion, and at least one slow-motion pass for nontrivial animation.
6. Report changes in grouped markdown tables with `Before`, `After`, and `Why` columns.

## Motion Decision Framework

Before animating, decide whether the animation earns its cost.

| User frequency | Default decision |
| --- | --- |
| 100+ times/day, keyboard shortcuts, command palette toggles | No animation |
| Tens of times/day, list navigation, repeated hovers | Remove or make nearly instant |
| Occasional modals, drawers, toasts, popovers | Standard restrained animation |
| Rare onboarding, celebration, explanatory moments | More expressive motion is acceptable |

Every animation needs a job:

- **Feedback**: show the UI heard the user, such as press scale.
- **Spatial consistency**: enter and exit from a direction that matches the component's physical model.
- **State indication**: morph or crossfade between meaningful states.
- **Explanation**: demonstrate a feature or process.
- **Softening discontinuity**: avoid abrupt mount/unmount or layout changes.

If the reason is only "looks cool" and users will see it often, remove it.

## Motion Defaults

Use these defaults unless the local design system already has better tokens.

| Interaction | Duration | Easing |
| --- | --- | --- |
| Button press feedback | `100-160ms` | ease-out |
| Tooltip or small popover | `125-200ms` | ease-out |
| Dropdown or select | `150-250ms` | ease-out |
| Modal or drawer | `200-300ms` for most apps, up to `500ms` when spatial context matters | custom ease-out or drawer curve |
| Decorative or explanatory animation | Longer is allowed if it does not block interaction | match the concept |

Prefer stronger custom curves over weak browser defaults:

```css
:root {
  --ease-out-ui: cubic-bezier(0.23, 1, 0.32, 1);
  --ease-in-out-ui: cubic-bezier(0.77, 0, 0.175, 1);
  --ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);
}
```

Do not use `ease-in` for visible UI entry. It delays the first movement and feels unresponsive.

## Motion Implementation Rules

- Use CSS transitions for interactive state changes because they retarget cleanly when interrupted.
- Use keyframes for one-shot sequences only: initial page reveal, skeleton shimmer, loading loops, or decorative staged effects.
- Use CSS or WAAPI for predetermined animations under load; use JS motion libraries for gestures, layout-aware transitions, and dynamic interactions.
- Animate `transform`, `opacity`, and occasionally `filter` or `clip-path`. Avoid animating `height`, `width`, `top`, `left`, `padding`, and `margin` unless the layout change is the point and performance is acceptable.
- Never use `transition: all` or Tailwind's generic `transition` class. Specify the exact properties: `transition-[transform,opacity]`, `transition-transform`, or explicit CSS.
- Add `will-change` only after noticing first-frame stutter, and only for compositor-friendly properties such as `transform`, `opacity`, `filter`, or `clip-path`.
- Respect `prefers-reduced-motion`: remove movement and large position changes, but keep gentle opacity/color transitions when they aid comprehension.
- Gate hover motion with `@media (hover: hover) and (pointer: fine)` so touch devices do not get sticky hover behavior.
- Do not animate keyboard-initiated high-frequency actions.

## Micro-Interactions

### Press Feedback

Pressable elements should normally scale to `0.96` on active press with a fast transform transition. Keep the scale between `0.95` and `0.98`; smaller values feel exaggerated.

```css
.button {
  transition-property: transform;
  transition-duration: 140ms;
  transition-timing-function: var(--ease-out-ui);
}

.button:active {
  transform: scale(0.96);
}
```

Skip press scale when it would disturb dense controls, text selection, drag handles, or reduced-motion preferences.

### Enter and Exit

- Do not animate one large container when content has clear semantic pieces. Split into title, body, primary actions, and secondary content.
- Stagger short groups by `30-80ms`; use about `100ms` only for larger hero or page-level reveals.
- Enter with `opacity`, small `translateY` (`8-12px`), and optionally `blur(2-4px)`.
- Exit faster than enter. Use subtle movement such as `translateY(-8px)` or `translateY(-12px)` instead of dramatic full-height exits unless spatial context requires it.
- Never enter from `scale(0)`. Start around `scale(0.95)` with `opacity: 0`.
- For default-state React `AnimatePresence`, use `initial={false}` unless an initial reveal is intentional.

### Icons and State Swaps

For contextual icons, keep the transition physical: opacity, scale, and blur.

- Enter: `opacity: 0 -> 1`, `scale: 0.25 -> 1`, `blur(4px) -> blur(0)`.
- Exit: reverse the same properties.
- If Motion is already installed, use a spring with `duration: 0.3` and `bounce: 0` for utilitarian UI.
- If no motion library is installed, keep both icons mounted, position one absolutely, and crossfade with CSS transitions.

### Popovers, Tooltips, Drawers, Toasts

- Popovers should scale from their trigger. Use component-library origin variables such as Radix `--radix-popover-content-transform-origin` when available. Modals stay centered.
- Tooltips should have an initial delay, then skip delay and animation while the user moves across adjacent tooltip targets.
- Drawers and toasts should enter and exit from the same spatial direction unless the product has a clear reason not to.
- For swipe or drag dismissal, consider velocity as well as distance. A quick flick should be enough even if distance is short.
- Capture pointer events during drag and ignore extra touch points after the drag starts.

## Surfaces

### Concentric Radius

For nested rounded surfaces, calculate:

```text
outer radius = inner radius + padding between them
```

This matters most when nested surfaces are visually close. If padding is larger than `24px`, treat them as separate surfaces and choose radii independently.

### Optical Alignment

Prefer optical alignment over geometric alignment when the eye disagrees with the math.

- Text + icon buttons often need `2px` less padding on the icon side.
- Play triangles usually need a small right shift.
- Asymmetric icons should ideally be fixed in the SVG viewBox; margin tweaks are a fallback.

### Shadows, Borders, and Image Outlines

- For cards, buttons, dropdowns, and elevated containers, prefer layered transparent `box-shadow` over hard borders when the border is acting as depth.
- Keep real borders for dividers, table boundaries, form inputs, and dense separators.
- Give images a subtle inset outline: `outline: 1px solid rgba(0, 0, 0, 0.1)` in light mode and `rgba(255, 255, 255, 0.1)` in dark mode. Use pure black or white, not tinted palette colors.

### Hit Areas

Interactive elements need at least a `40x40px` hit area, ideally `44x44px` where layout allows. If the visible control is smaller, extend the target with a pseudo-element. Extended hit areas must not overlap neighboring controls.

## Typography

- Apply font smoothing once at the root: `-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale;` or Tailwind `antialiased`.
- Use `text-wrap: balance` for headings and short title blocks.
- Use `text-wrap: pretty` for short-to-medium paragraphs, descriptions, captions, and list text.
- Do not use balance or pretty on long prose, code blocks, or preformatted content.
- Use tabular numbers for counters, timers, updating prices, numeric table columns, scoreboards, and dashboards.

## Performance and Accessibility Checks

- Confirm no `transition: all`, `will-change: all`, or broad Tailwind `transition` classes remain in changed UI.
- Confirm moving elements rely on transform rather than layout properties where practical.
- Check reduced motion behavior for all nontrivial animation.
- Check focus visibility after replacing borders with shadows.
- Check hover behavior on touch-sized controls.
- Test nontrivial animation slowly in DevTools or by temporarily multiplying duration.

## Review Output

When reviewing or summarizing polish work, group findings by principle and use markdown tables.

```markdown
#### Motion
| Before | After | Why |
| --- | --- | --- |
| `transition: all 300ms ease-in` | `transition: transform 180ms var(--ease-out-ui)` | Exact property and faster first response |

#### Surfaces
| Before | After | Why |
| --- | --- | --- |
| Card and child both `rounded-xl` with `p-2` | Outer `rounded-2xl`, inner `rounded-lg` | Radius now follows outer = inner + padding |
```

Omit sections where nothing changed. Cite files and properties when the diff is not obvious.
