<!--
  Brand (DESIGN.md, Theming): accentFromColor(brand) gives the pair; set it on the root region. It replaces the
  neutral accent where no content leads — here, the whole mock shell below the picker.
-->
<script lang="ts">
  import { accentFromColor } from '@tsuya/core';
  import { AccentRegion, Button, Surface } from '@tsuya/svelte';

  let brand = $state('#7c3aed');
  const pair = $derived(accentFromColor(brand));
</script>

<label class="picker t-body">
  Brand colour
  <input type="color" defaultValue={brand} oninput={(event) => (brand = event.currentTarget.value)} />
  <code class="t-mono">{brand}</code>
</label>

<AccentRegion {pair} style="display: contents">
  <Surface class="shell">
    <div class="bar">
      <span class="t-title-s">Acme</span>
      <Button size="sm">Create</Button>
    </div>
  </Surface>
</AccentRegion>

<style>
  .picker {
    display: inline-flex;
    align-items: center;
    gap: var(--t-space-8);
    margin-top: var(--t-space-16);
  }
  :global(.shell) {
    margin-top: var(--t-space-16);
    padding: var(--t-space-16);
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
  }
  .bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
</style>
