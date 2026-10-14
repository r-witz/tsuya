<!--
  Grain (DESIGN.md, Grain): Surface's three modes, side by side.
-->
<script lang="ts">
  import { Surface } from '@tsuya/svelte';

  const MODES = [
    { grain: 'bg' as const, note: 'Default: under the content.' },
    { grain: 'all' as const, note: 'Poster-like pages: over content too, never over text inputs.' },
    { grain: 'off' as const, note: 'No grain.' },
  ];
</script>

<div class="grain-row">
  {#each MODES as mode (mode.grain)}
    <Surface class="grain-box" grain={mode.grain}>
      <p class="t-mono t-caption">data-grain="{mode.grain}"</p>
      <p class="t-caption t-muted">{mode.note}</p>
    </Surface>
  {/each}
</div>

<style>
  .grain-row {
    display: flex;
    flex-wrap: wrap;
    gap: var(--t-space-16);
    margin-top: var(--t-space-16);
  }
  :global(.grain-box) {
    flex: 1 1 180px;
    padding: var(--t-space-16);
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
  }
</style>
