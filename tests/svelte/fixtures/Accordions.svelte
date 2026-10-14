<!-- The questions of a shop, in an accordion; one of them holds a button. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Accordion, Button, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    type?: 'single' | 'multiple';
    value?: string[];
    disabled?: string;
  }

  let { type = 'single', value = $bindable([]), disabled }: Props = $props();

  const items = [
    { value: 'shipping', title: 'Shipping', body: 'Orders leave the warehouse within two days.' },
    { value: 'returns', title: 'Returns', body: 'Return any item within 30 days.' },
    { value: 'warranty', title: 'Warranty', body: 'Two years on every product.' },
  ];
</script>

<TsuyaProvider labels={labelsEn}>
  <div style="max-width: 480px; padding: var(--t-space-16)">
    <Accordion.Root {type} bind:value>
      {#each items as item (item.value)}
        <Accordion.Item value={item.value} disabled={item.value === disabled}>
          <Accordion.Trigger>{item.title}</Accordion.Trigger>
          <Accordion.Content>
            <p style="margin: 0">{item.body}</p>
            {#if item.value === 'returns'}<Button size="sm">Start a return</Button>{/if}
          </Accordion.Content>
        </Accordion.Item>
      {/each}
    </Accordion.Root>
    <output data-testid="value">{value.join(',')}</output>
  </div>
</TsuyaProvider>
