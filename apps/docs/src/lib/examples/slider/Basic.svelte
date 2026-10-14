<script lang="ts">
  import { Slider } from '@tsuya/svelte';

  let volume = $state(0.4);
</script>

<div class="row">
  <Slider bind:value={volume} label="Volume" />
  <output class="t-control">{Math.round(volume * 100)} %</output>
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
