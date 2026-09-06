# Mermaid guidance

Load Mermaid only when a relationship, process, sequence, hierarchy, or state change is clearer as a diagram. Add this module script in the document head:

```html
<script type="module">
  import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
  mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "strict" });
</script>
```

Wrap the diagram in a restrained figure with a caption. Prefer simple syntax. Simplify a crowded diagram or use another visual form instead of forcing Mermaid to carry too much information.
