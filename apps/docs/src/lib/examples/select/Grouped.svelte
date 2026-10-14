<script lang="ts">
  import { Select } from '@tsuya/svelte';

  let city = $state<string>();
</script>

<div class="wide">
  <Select
    bind:value={city}
    label="City"
    hint="Groups are kept in the order of the options."
    options={[
      { value: 'paris', label: 'Paris', group: 'France' },
      { value: 'lyon', label: 'Lyon', group: 'France' },
      { value: 'berlin', label: 'Berlin', group: 'Germany' },
      { value: 'munich', label: 'Munich', group: 'Germany' },
      { value: 'rome', label: 'Rome', group: 'Italy', disabled: true },
    ]}
  />
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
