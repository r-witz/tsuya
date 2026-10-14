<!-- A select, a combobox, a menu or a tooltip on the start side, in a row, to put in a narrow window. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, Combobox, Menu, Select, TsuyaProvider, Tooltip } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    kind: 'select' | 'combobox' | 'menu' | 'tooltip';
    /** The width of the control, in pixels; its container's whole width when missing. */
    width?: number;
    /** Padding of the row, in pixels. */
    pad?: number;
    dir?: 'ltr' | 'rtl';
    /** Where the control sits in the row. */
    align?: 'start' | 'center' | 'end';
  }

  let { kind, width, pad = 0, dir = 'ltr', align = 'start' }: Props = $props();
  const justify = { start: 'flex-start', center: 'center', end: 'flex-end' };
  const options = [
    { value: 'a', label: 'Short' },
    { value: 'long', label: 'A rather long label that has to wrap or ellipsize at three hundred percent' },
  ];
</script>

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="display: flex; justify-content: {justify[align]}; padding: {pad}px">
    <div style={width ? `width: ${String(width)}px` : 'width: 100%'}>
      {#if kind === 'select'}
        <Select label="Pick" {options} sheetOnPhone={false} />
      {:else if kind === 'combobox'}
        <Combobox label="Search" {options} />
      {:else if kind === 'menu'}
        <Menu.Root>
          <Menu.Trigger>Actions</Menu.Trigger>
          <Menu.Content><Menu.Item onselect={() => {}}>Rename</Menu.Item></Menu.Content>
        </Menu.Root>
      {:else}
        <Tooltip
          text="Copy the link to this photo album so that you can paste it into a message and share it with anyone"
          side="start"
        >
          {#snippet trigger(props)}<Button {...props}>Copy link</Button>{/snippet}
        </Tooltip>
      {/if}
    </div>
  </div>
</TsuyaProvider>
