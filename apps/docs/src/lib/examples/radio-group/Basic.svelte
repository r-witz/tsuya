<script lang="ts">
  import { Radio, RadioGroup } from '@tsuya/svelte';

  let size = $state('m');
</script>

<RadioGroup bind:value={size} name="size" label="Size">
  <Radio value="s">Small</Radio>
  <Radio value="m">Medium</Radio>
  <Radio value="l">Large</Radio>
</RadioGroup>
