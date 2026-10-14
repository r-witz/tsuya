<!-- A select of countries in a form, and a composed select of sizes; on a phone, either in a sheet or not. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, Select, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    country?: string;
    size?: string;
    disabled?: boolean;
    required?: boolean;
    error?: string;
    glass?: boolean;
    dir?: 'ltr' | 'rtl';
    sheetOnPhone?: boolean;
  }

  let {
    country = $bindable(),
    size = $bindable('m'),
    disabled = false,
    required = false,
    error,
    glass = false,
    dir = 'ltr',
    sheetOnPhone = true,
  }: Props = $props();

  const europe = ['France', 'Germany', 'Greece', 'Italy', 'Spain'].map((label) => ({
    value: label.slice(0, 2).toUpperCase(),
    label,
    group: 'Europe',
  }));
  const asia = Array.from({ length: 25 }, (_, i) => ({
    value: `A${String(i)}`,
    label: `Asia ${String(i + 1)}`,
    group: 'Asia',
  }));
</script>

<TsuyaProvider labels={labelsEn}>
  <form data-testid="form" {dir} class={glass ? 't-glass-control' : undefined} style="max-width: 320px; margin: 40px">
    <Select
      label="Country"
      placeholder="Choose a country"
      bind:value={country}
      options={[...europe, ...asia]}
      name="country"
      {disabled}
      {required}
      {error}
      {sheetOnPhone}
    />
  </form>
  <Button style="position: fixed; top: 8px; right: 8px">After</Button>
  <Select.Root bind:value={size} label="Size" {sheetOnPhone} items={[{ value: 'm', label: 'Medium' }]}>
    <Select.Trigger aria-label="Size" placeholder="Size" />
    <Select.Content>
      <Select.Item value="s" label="Small" />
      <Select.Separator />
      <Select.Item value="m" label="Medium" />
      <Select.Item value="l" label="Large" disabled />
      <Select.Item value="xl" label="Extra large" />
    </Select.Content>
  </Select.Root>
</TsuyaProvider>
