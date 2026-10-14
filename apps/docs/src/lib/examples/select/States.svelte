<script lang="ts">
  import { Select } from '@tsuya/svelte';

  let country = $state<string>();
  let plan = $state('team');
</script>

<div class="stack">
  <Select
    bind:value={country}
    label="Country"
    placeholder="Choose a country"
    required
    error="Choose the country of your billing address."
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
  <Select
    bind:value={plan}
    label="Plan"
    disabled
    options={[
      { value: 'free', label: 'Free' },
      { value: 'team', label: 'Team' },
    ]}
  />
</div>

<style>
  .stack {
    display: grid;
    gap: var(--t-space-16);
    width: min(100%, 24rem);
  }
</style>
