<!-- Don't: a number the user has to hit exactly is a TextInput; a slider hides it and cannot be typed into. -->
<script lang="ts">
  import { Slider } from '@tsuya/svelte';

  let amount = $state(420);
</script>

<div class="row">
  <Slider bind:value={amount} label="Transfer amount" min={0} max={1000} />
</div>

<style>
  .row {
    display: flex;
    width: 100%;
  }
  .row :global(.t-slider) {
    flex: 1;
  }
</style>
