<!--
  The type scale (DESIGN.md, Type): every style set the documented way, a font shorthand and a tracking, so the
  sample can never drift from the token ("font: var(--t-type-body); letter-spacing: var(--t-type-body-tracking)").
-->
<script lang="ts">
  import { typeRows } from '#lib/content/foundations.ts';
</script>

{#each typeRows as row (row.name)}
  <div class="type-row">
    <p class="sample" style="font: var({row.cssVar}); letter-spacing: var({row.trackingVar})">
      The quick brown fox jumps over the lazy dog.
    </p>
    <p class="meta t-caption t-muted">
      <code class="t-mono">{row.cssVar}</code> · {row.fontWeight} · {row.fontSize}px
    </p>
  </div>
{/each}

<style>
  .type-row {
    padding: var(--t-space-16) 0;
    border-bottom: 1px solid var(--t-border);
  }
  .type-row:first-child {
    padding-top: 0;
  }
  .sample {
    margin: 0;
    color: var(--t-text);
  }
  .meta {
    margin: var(--t-space-8) 0 0;
  }
</style>
