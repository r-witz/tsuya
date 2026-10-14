<!-- A radio group of sizes, one disabled. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Radio, RadioGroup, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    value?: string;
    disabled?: boolean;
  }

  let { value = $bindable('md'), disabled = false }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <div style="padding: var(--t-space-16)">
    <RadioGroup bind:value name="size" label="Size">
      <Radio value="sm">Small</Radio>
      <Radio value="md">Medium</Radio>
      <Radio value="lg" {disabled}>Large</Radio>
    </RadioGroup>
  </div>
</TsuyaProvider>
