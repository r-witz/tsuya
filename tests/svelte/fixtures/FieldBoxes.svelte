<!-- The three field boxes: a text input, a text area and a select's trigger, invalid or disabled at will. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Select, Textarea, TextInput, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  let { invalid = false, disabled = false }: { invalid?: boolean; disabled?: boolean } = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <div style="display: flex; flex-direction: column; gap: var(--t-space-16); max-width: 320px">
    <TextInput aria-label="Text" aria-invalid={invalid || undefined} {disabled} />
    <Textarea aria-label="Area" aria-invalid={invalid || undefined} {disabled} />
    <Select.Root label="Choice" items={[{ value: 'a', label: 'A' }]} {disabled}>
      <Select.Trigger aria-label="Choice" aria-invalid={invalid || undefined} placeholder="Choose" />
      <Select.Content><Select.Item value="a" label="A" /></Select.Content>
    </Select.Root>
  </div>
</TsuyaProvider>
