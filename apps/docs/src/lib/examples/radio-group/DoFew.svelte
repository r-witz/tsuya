<script lang="ts">
  import { Radio, RadioGroup } from '@tsuya/svelte';

  let delivery = $state('standard');
</script>

<RadioGroup bind:value={delivery} name="delivery" label="Delivery">
  <Radio value="standard">Standard, 3 days</Radio>
  <Radio value="express">Express, next day</Radio>
  <Radio value="pickup">Pick up in store</Radio>
</RadioGroup>
