<!-- A combobox of cities in a form. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, Combobox, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    value?: string;
    inputValue?: string;
    options?: { value: string; label: string; disabled?: boolean }[];
    freeText?: boolean;
    loading?: boolean;
    disabled?: boolean;
    error?: string;
    dir?: 'ltr' | 'rtl';
  }

  const cities = ['Paris', 'Lyon', 'Lille', 'Marseille', 'Nantes', 'Nice', 'Toulouse'].map((label) => ({
    value: label.slice(0, 3).toUpperCase(),
    label,
  }));

  let {
    value = $bindable(),
    inputValue = $bindable(''),
    options = cities,
    freeText = false,
    loading = false,
    disabled = false,
    error,
    dir = 'ltr',
  }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <form data-testid="form" {dir} style="max-width: 320px; margin: 40px">
    <Combobox
      label="City"
      placeholder="Search a city"
      bind:value
      bind:inputValue
      {options}
      name="city"
      {freeText}
      {loading}
      {disabled}
      {error}
    />
    <Button>After</Button>
  </form>
</TsuyaProvider>
