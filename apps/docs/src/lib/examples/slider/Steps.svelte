<script lang="ts">
  import { Slider } from '@tsuya/svelte';

  let zoom = $state(100);
</script>

<div class="row">
  <Slider bind:value={zoom} label="Zoom" min={50} max={200} step={10} valueLabel={(value) => `${String(value)} %`} />
  <output class="t-control">{zoom} %</output>
</div>

<style>
  .row {
    display: flex;
    align-items: center;
    gap: var(--t-space-12);
    width: min(100%, 24rem);
  }
  .row :global(.t-slider) {
    flex: 1;
  }
</style>
