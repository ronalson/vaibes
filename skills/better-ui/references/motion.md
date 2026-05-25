# Motion Reference

Use this when implementing or reviewing animations, hover states, press states, popovers, tooltips, toasts, drawers, icon swaps, or gestures.

## Interruptibility

Use CSS transitions for interactive state changes because they can be interrupted and retargeted mid-animation. Reserve keyframes for staged sequences that run once.

```css
/* Good: retargets smoothly when toggled mid-animation */
.drawer {
  transform: translateX(-100%);
  transition: transform 200ms var(--ease-out-ui);
}

.drawer[data-open="true"] {
  transform: translateX(0);
}
```

Avoid keyframes for rapidly triggered UI such as drawers, toggles, toasts, and command palette open/close behavior. Keyframes restart from the beginning and can feel disconnected from user intent.

## Should It Animate?

| Frequency | Decision |
| --- | --- |
| Keyboard actions, command palette toggles, actions used hundreds of times daily | No animation |
| Repeated navigation and dense hover work | Remove, shorten, or restrict to color/opacity |
| Occasional modals, drawers, popovers, dropdowns, toasts | Use standard restrained motion |
| Rare onboarding, feedback, explanation, celebration | Expressive motion can be appropriate |

Never animate keyboard-initiated high-frequency actions.

## Easing and Duration

```css
:root {
  --ease-out-ui: cubic-bezier(0.23, 1, 0.32, 1);
  --ease-in-out-ui: cubic-bezier(0.77, 0, 0.175, 1);
  --ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);
}
```

| Element | Duration | Easing |
| --- | --- | --- |
| Button press feedback | `100-160ms` | ease-out |
| Tooltip or small popover | `125-200ms` | ease-out |
| Dropdown or select | `150-250ms` | ease-out |
| Modal or drawer | `200-300ms`, up to `500ms` when spatial context matters | custom ease-out or drawer curve |
| Constant motion | context-dependent | linear |

Avoid `ease-in` for UI entry. It starts slowly at the moment the user expects immediate response.

## Press Feedback

Use subtle scale on press for buttons and pressable elements.

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

Use `0.96` by default. Stay between `0.95` and `0.98`. Skip press scale for dense tables, text selection controls, drag handles, and reduced-motion contexts.

## Enter Animations

Split content into logical groups instead of animating one large container. For page sections, use title, description, actions, and supporting content. For cards or list items, animate each item with short stagger.

```css
.stagger-item {
  opacity: 0;
  transform: translateY(10px);
  filter: blur(4px);
  animation: better-ui-enter 320ms var(--ease-out-ui) forwards;
}

.stagger-item:nth-child(1) { animation-delay: 0ms; }
.stagger-item:nth-child(2) { animation-delay: 60ms; }
.stagger-item:nth-child(3) { animation-delay: 120ms; }

@keyframes better-ui-enter {
  to {
    opacity: 1;
    transform: translateY(0);
    filter: blur(0);
  }
}
```

Use `30-80ms` stagger for most UI. Use about `100ms` only for slower page-level reveals. Stagger is decorative; never block interaction while it plays.

Use `@starting-style` when browser support is acceptable:

```css
.toast {
  opacity: 1;
  transform: translateY(0);
  transition: opacity 240ms var(--ease-out-ui), transform 240ms var(--ease-out-ui);

  @starting-style {
    opacity: 0;
    transform: translateY(100%);
  }
}
```

## Exit Animations

Exits should be quieter and faster than enters.

```css
.item[data-exiting="true"] {
  opacity: 0;
  transform: translateY(-10px);
  filter: blur(4px);
  transition:
    opacity 150ms ease,
    transform 150ms ease,
    filter 150ms ease;
}
```

Use full-distance exits only when spatial context matters, such as drawers or cards returning to a list.

## Scale and Transform Origin

Never animate entry from `scale(0)`. Start around `scale(0.95)` with opacity.

```css
.popover[data-starting-style],
.popover[data-ending-style] {
  opacity: 0;
  transform: scale(0.95);
}
```

Popovers should scale from their trigger, not the center. Use library-provided origin variables:

```css
.popover {
  transform-origin: var(--radix-popover-content-transform-origin);
}
```

Modals are the exception: centered modals should keep `transform-origin: center`.

## Icon and State Swaps

For contextual icon changes, animate opacity, scale, and blur rather than toggling display.

Use these values:

- `scale: 0.25 -> 1`
- `opacity: 0 -> 1`
- `filter: blur(4px) -> blur(0)`

If Motion is already installed, use:

```tsx
transition={{ type: "spring", duration: 0.3, bounce: 0 }}
```

If no motion library exists, keep both icons mounted. Put one absolute over the other and crossfade both.

```tsx
<span className="relative grid place-items-center">
  <span className="absolute inset-0 grid place-items-center transition-[opacity,filter,scale] duration-300 data-[active=false]:scale-[0.25] data-[active=false]:opacity-0 data-[active=false]:blur-[4px]">
    <ActiveIcon />
  </span>
  <span className="grid place-items-center transition-[opacity,filter,scale] duration-300 data-[active=true]:scale-[0.25] data-[active=true]:opacity-0 data-[active=true]:blur-[4px]">
    <InactiveIcon />
  </span>
</span>
```

## Tooltips

Tooltips should delay on first hover to avoid accidental activation. Once a tooltip is open, adjacent tooltips should open instantly and usually without animation. This makes toolbars feel fast without making the first tooltip noisy.

```css
.tooltip {
  transform-origin: var(--transform-origin);
  transition:
    opacity 125ms var(--ease-out-ui),
    transform 125ms var(--ease-out-ui);
}

.tooltip[data-starting-style],
.tooltip[data-ending-style] {
  opacity: 0;
  transform: scale(0.97);
}

.tooltip[data-instant="true"] {
  transition-duration: 0ms;
}
```

## Gestures and Drag

- Dismiss with velocity as well as distance. A quick flick should work even when distance is short.
- Apply damping or friction past natural boundaries instead of hard stops.
- Capture pointer events once dragging starts so the gesture continues outside the element.
- Ignore extra touch points after the initial drag starts to avoid jumps.

Example velocity rule:

```ts
const elapsed = Date.now() - dragStartedAt;
const velocity = Math.abs(distance) / elapsed;

if (Math.abs(distance) >= threshold || velocity > 0.11) {
  dismiss();
}
```

## Clip-Path Patterns

`clip-path: inset()` is useful for reveal effects, hold-to-confirm overlays, tab color transitions, image comparisons, and scroll reveals.

```css
.hold-overlay {
  clip-path: inset(0 100% 0 0);
  transition: clip-path 200ms var(--ease-out-ui);
}

.button:active .hold-overlay {
  clip-path: inset(0 0 0 0);
  transition: clip-path 2s linear;
}
```

Use slow timing while the user is deciding, and fast timing on release.

## Debugging

- Slow nontrivial animations to 2-5x duration and inspect timing, origin, overlap, and easing.
- Use DevTools animation inspection for frame-by-frame checks when motion still feels off.
- Test drag/swipe behavior on a real touch device when practical.
- Check that reduced-motion mode removes large movement while preserving useful opacity/color feedback.
