<script lang="ts">
  import { Combobox } from '@tsuya/svelte';

  let city = $state<string>();
</script>

<div class="wide">
  <Combobox
    bind:value={city}
    label="City"
    placeholder="Type to filter"
    options={[
      { value: 'paris', label: 'Paris' },
      { value: 'lyon', label: 'Lyon' },
      { value: 'lille', label: 'Lille' },
      { value: 'nantes', label: 'Nantes' },
      { value: 'nice', label: 'Nice' },
      { value: 'toulouse', label: 'Toulouse' },
      { value: 'bordeaux', label: 'Bordeaux' },
    ]}
  />
</div>

<style>
  .wide {
    width: 100%;
  }
</style>
