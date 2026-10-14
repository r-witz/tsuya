<script lang="ts">
  import { Select } from '@tsuya/svelte';

  let country = $state('fr');
</script>

<div class="wide">
  <Select
    bind:value={country}
    label="Country"
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
    width: 100%;
  }
</style>
