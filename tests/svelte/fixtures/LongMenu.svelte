<!-- Anchored panels with long labels, their triggers at the end edge: a menu, a popover, a select and a combobox. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Combobox, Menu, Popover, Select, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  const long = 'A rather long label that has to wrap or ellipsize at three hundred percent';
  const options = [{ value: 'long', label: long }];
</script>

<TsuyaProvider labels={labelsEn}>
  <div style="display: flex; flex-direction: column; align-items: flex-end; padding: 16px; gap: 8px">
    <Menu.Root>
      <Menu.Trigger>Actions</Menu.Trigger>
      <Menu.Content>
        <Menu.Item onselect={() => {}}>{long}</Menu.Item>
      </Menu.Content>
    </Menu.Root>
    <Popover.Root>
      <Popover.Trigger>Info</Popover.Trigger>
      <Popover.Content><p>{long}</p></Popover.Content>
    </Popover.Root>
    <div style="width: 120px">
      <Select label="Pick" {options} sheetOnPhone={false} />
    </div>
    <div style="width: 120px">
      <Combobox label="Search" {options} />
    </div>
  </div>
</TsuyaProvider>
