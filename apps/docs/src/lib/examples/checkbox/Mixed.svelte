<script lang="ts">
  import { Checkbox } from '@tsuya/svelte';

  let items = $state([
    { label: 'Email', on: true },
    { label: 'Push', on: false },
    { label: 'SMS', on: false },
  ]);

  const all = $derived(items.every((item) => item.on));
  const some = $derived(items.some((item) => item.on));
</script>

<div class="group">
  <Checkbox
    checked={all}
    indeterminate={some && !all}
    onchange={(event) => {
      for (const item of items) item.on = event.currentTarget.checked;
    }}
  >
    All notifications
  </Checkbox>
  <div class="items">
    {#each items as item (item.label)}
      <Checkbox bind:checked={item.on}>{item.label}</Checkbox>
    {/each}
  </div>
</div>

<style>
  .items {
    display: grid;
    padding-inline-start: var(--t-space-24);
  }
</style>
