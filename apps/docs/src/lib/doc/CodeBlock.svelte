<!--
  A code block highlighted at build time (#lib/server/highlight.ts). `html` is
  shiki's dual-theme output; it renders and colours itself the same way everywhere (app.css's `.shiki` rules), so
  this component only places it.
-->
<script lang="ts">
  let { html }: { html: string } = $props();
</script>

<!-- eslint-disable-next-line svelte/no-at-html-tags -- shiki output, generated at build time from our own code -->
{@html html}
