<!-- A dialog, a bottom sheet or a side sheet, open, with a toast button, a select and (in the dialog) a sheet of its own. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, Dialog, Select, Sheet, TsuyaProvider, toast } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    kind?: 'dialog' | 'sheet' | 'sheet-end';
    open?: boolean;
    sheetOpen?: boolean;
    withDescription?: boolean;
    withTitle?: boolean;
    dismissible?: boolean;
  }

  let {
    kind = 'dialog',
    open = $bindable(true),
    sheetOpen = $bindable(false),
    withDescription = false,
    withTitle = true,
    dismissible = true,
  }: Props = $props();
  let value = $state<string | undefined>();
  const options = [
    { value: 'FR', label: 'France' },
    { value: 'DE', label: 'Germany' },
  ];
</script>

<TsuyaProvider labels={labelsEn}>
  {#if kind === 'dialog'}
    <Dialog.Root bind:open {dismissible}>
      <Dialog.Content data-testid="content">
        {#if withTitle}<Dialog.Title>Outer dialog</Dialog.Title>{/if}
        {#if withDescription}<Dialog.Description>Some detail.</Dialog.Description>{/if}
        <Button
          onclick={() => {
            toast('Saved');
          }}>Notify</Button
        >
        <Select label="Country" bind:value {options} />
        <Sheet.Root bind:open={sheetOpen}>
          <Button
            onclick={() => {
              sheetOpen = true;
            }}>Open sheet</Button
          >
          <Sheet.Content>
            <Sheet.Title>Inner sheet</Sheet.Title>
            <Button>In sheet</Button>
          </Sheet.Content>
        </Sheet.Root>
      </Dialog.Content>
    </Dialog.Root>
  {:else}
    <Sheet.Root bind:open side={kind === 'sheet' ? 'bottom' : 'end'}>
      <Sheet.Content data-testid="content">
        {#if withTitle}<Sheet.Title>Outer sheet</Sheet.Title>{/if}
        <Button
          onclick={() => {
            toast('Saved');
          }}>Notify</Button
        >
        <Select label="Country" bind:value {options} />
      </Sheet.Content>
    </Sheet.Root>
  {/if}
</TsuyaProvider>
