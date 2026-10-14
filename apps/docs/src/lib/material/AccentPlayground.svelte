<!--
  The accent engine from a brand colour (DESIGN.md, Accent, The engine): accentFromColor(seed) clamps the seed's
  lightness into each mode's band, keeps its hue, and turns it away from the four statuses. Both modes are shown at
  once, not behind a toggle, since a pair always carries both; --t-on-accent is a fixed token, guaranteed to keep
  5.3:1 against any accent of the band, which the live ratio below checks for whatever seed is picked.
-->
<script lang="ts">
  import { accentFromColor, contrast } from '@tsuya/core';
  import { dark, light } from '@tsuya/core/tokens';
  import { AccentRegion, Surface } from '@tsuya/svelte';

  let { seed = $bindable('#1fb8a6') }: { seed?: string } = $props();

  const pair = $derived(accentFromColor(seed));
</script>

<label class="picker t-body">
  Seed colour
  <!-- `defaultValue` renders as the `value` attribute, which hydration leaves; a colour input with no value logs a
       browser warning -->
  <input type="color" defaultValue={seed} oninput={(event) => (seed = event.currentTarget.value)} />
  <code class="t-mono">{seed}</code>
</label>

<div class="panels">
  <Surface class="panel" data-theme="light">
    <p class="t-caption t-muted">Light</p>
    <AccentRegion {pair}>
      <span class="chip">Create</span>
    </AccentRegion>
    <p class="t-mono t-caption">
      {pair.light} · on-accent {contrast(light.color.onAccent, pair.light).toFixed(2)}:1
    </p>
  </Surface>
  <Surface class="panel" data-theme="dark">
    <p class="t-caption t-muted">Dark</p>
    <AccentRegion {pair}>
      <span class="chip">Create</span>
    </AccentRegion>
    <p class="t-mono t-caption">
      {pair.dark} · on-accent {contrast(dark.color.onAccent, pair.dark).toFixed(2)}:1
    </p>
  </Surface>
</div>

<style>
  .picker {
    display: inline-flex;
    align-items: center;
    gap: var(--t-space-8);
    margin-top: var(--t-space-16);
  }
  .panels {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: var(--t-space-16);
    margin-top: var(--t-space-16);
  }
  :global(.panel) {
    padding: var(--t-space-16);
    border-radius: var(--t-radius-md);
    border: 1px solid var(--t-border);
  }
  .chip {
    display: inline-flex;
    align-items: center;
    margin-top: var(--t-space-8);
    padding: var(--t-space-8) var(--t-space-16);
    border-radius: var(--t-radius-full);
    background: var(--t-accent);
    color: var(--t-on-accent);
    font: var(--t-type-button);
    letter-spacing: var(--t-type-button-tracking);
  }
  .t-mono.t-caption {
    display: block;
    margin-top: var(--t-space-8);
    color: var(--t-text-muted);
  }
</style>
