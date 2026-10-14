<!--
  Glass (DESIGN.md, Glass): tinted (the default, one content leads) and neutral (settings, forms, grids, brand
  screens), both over the same artwork — glass never sits on a flat background. The tint comes from the accent
  region around it, the same pair the playground above computed.
-->
<script lang="ts">
  import type { AccentPair } from '@tsuya/core';
  import { AccentRegion, GlassScope } from '@tsuya/svelte';

  let { pair }: { pair: AccentPair } = $props();
</script>

<div class="art">
  <AccentRegion {pair} style="display: contents">
    <div class="glass t-glass" data-shadow="lg">
      <p class="t-body-strong">Tinted</p>
      <p class="t-caption t-muted">The default: the fill mixes in the accent.</p>
    </div>
    <GlassScope neutral>
      <div class="glass t-glass" data-shadow="lg">
        <p class="t-body-strong">Neutral</p>
        <p class="t-caption t-muted">Settings, forms, grids, brand screens.</p>
      </div>
    </GlassScope>
  </AccentRegion>
</div>

<style>
  .art {
    display: flex;
    flex-wrap: wrap;
    gap: var(--t-space-16);
    padding: var(--t-space-24);
    margin-top: var(--t-space-16);
    border-radius: var(--t-radius-md);
    background: linear-gradient(135deg, #1fb8a6, #0c2b3a);
  }
  .glass {
    flex: 1 1 200px;
    padding: var(--t-space-16);
  }
</style>
