<script lang="ts">
  import { Slider } from '@tsuya/svelte';

  let brightness = $state(0.65);
</script>

<div class="row">
  <Slider bind:value={brightness} label="Brightness" />
  <output class="t-control">{Math.round(brightness * 100)} %</output>
</div>

<style>
  .row {
    display: flex;
    align-items: center;
    gap: var(--t-space-12);
    width: 100%;
  }
  .row :global(.t-slider) {
    flex: 1;
  }
</style>
