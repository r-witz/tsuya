<script lang="ts">
  import { Select } from '@tsuya/svelte';

  let country = $state<string>();
</script>

<div class="wide">
  <Select
    bind:value={country}
    label="Country"
    placeholder="Choose a country"
    options={[
      { value: 'fr', label: 'France' },
      { value: 'de', label: 'Germany' },
      { value: 'it', label: 'Italy' },
      { value: 'es', label: 'Spain' },
      { value: 'pt', label: 'Portugal' },
      { value: 'be', label: 'Belgium' },
      { value: 'nl', label: 'Netherlands' },
    ]}
  />
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
