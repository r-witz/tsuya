<script lang="ts">
  import { Checkbox, Popover, Slider } from '@tsuya/svelte';

  let open = $state(false);
  let inStock = $state(true);
  let onSale = $state(false);
  let price = $state(60);
</script>

<Popover.Root bind:open>
  <Popover.Trigger>Filters</Popover.Trigger>
  <Popover.Content>
    <Checkbox bind:checked={inStock}>In stock</Checkbox>
    <Checkbox bind:checked={onSale}>On sale</Checkbox>
    <Slider bind:value={price} label="Maximum price" min={0} max={100} />
  </Popover.Content>
</Popover.Root>
