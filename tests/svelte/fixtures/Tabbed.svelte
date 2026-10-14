<!-- Tabs of a product page, or a dozen that do not fit, each with its panel. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Tabs, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    value?: string;
    manual?: boolean;
    dir?: 'ltr' | 'rtl';
    many?: boolean;
    disabled?: string;
  }

  let { value = $bindable(), manual = false, dir = 'ltr', many = false, disabled }: Props = $props();

  const names = $derived(
    many ? Array.from({ length: 12 }, (_, i) => `Section ${String(i + 1)}`) : ['Overview', 'Reviews', 'Details'],
  );
</script>

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="max-width: 360px; padding: var(--t-space-16)">
    <Tabs.Root bind:value {manual}>
      <Tabs.List aria-label="Product">
        {#each names as name (name)}
          <Tabs.Trigger value={name} disabled={name === disabled}>{name}</Tabs.Trigger>
        {/each}
      </Tabs.List>
      {#each names as name (name)}
        <Tabs.Content value={name}><p>The {name.toLowerCase()} of the product.</p></Tabs.Content>
      {/each}
    </Tabs.Root>
    <output data-testid="value">{value ?? ''}</output>
  </div>
</TsuyaProvider>
