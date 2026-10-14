<!--
  Fonts and radii (DESIGN.md, Theming): "--t-font-sans, --t-radius-xs to --t-radius-lg may be overridden." Scoped to
  this demo box only, with a plain CSS custom property, the same way an app would scope it to its own root.
-->
<script lang="ts">
  import { radius } from '@tsuya/core/tokens';
  import { SegmentedControl } from '@tsuya/svelte';

  const FONTS = [
    { value: 'Inter, system-ui, sans-serif', label: 'Inter (default)' },
    { value: 'Georgia, serif', label: 'Georgia' },
    { value: '"Courier New", monospace', label: 'Courier New' },
  ];

  let font = $state(FONTS[0]?.value ?? '');
  let cornerRadius = $state(radius.md);
</script>

<div class="row">
  <SegmentedControl label="Font" options={FONTS} bind:value={font} />
</div>
<div class="row">
  <label class="t-body" for="radius-range">Radius</label>
  <input id="radius-range" type="range" min="0" max="32" bind:value={cornerRadius} />
  <code class="t-mono">{cornerRadius}px</code>
</div>

<div class="demo" style="--t-font-sans: {font}; --t-radius-md: {cornerRadius}px">
  <p class="t-title-m">The quick brown fox</p>
  <button class="card t-body">A card using --t-radius-md</button>
</div>

<style>
  .row {
    display: flex;
    align-items: center;
    gap: var(--t-space-12);
    margin-top: var(--t-space-16);
  }
  .demo {
    margin-top: var(--t-space-16);
    padding: var(--t-space-24);
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
  }
  .card {
    display: block;
    margin-top: var(--t-space-16);
    padding: var(--t-space-16);
    border: 1px solid var(--t-border-strong);
    border-radius: var(--t-radius-md);
    background: var(--t-fill);
    color: var(--t-text);
  }
</style>
