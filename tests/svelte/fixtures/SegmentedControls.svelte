<!-- A segmented control of three options, with an icon-only variant and a disabled option. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { SegmentedControl, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    value?: string;
    expand?: boolean;
    icons?: boolean;
    dir?: 'ltr' | 'rtl';
    long?: boolean;
  }

  let { value = $bindable(), expand = false, icons = false, dir = 'ltr', long = false }: Props = $props();
</script>

{#snippet gridIcon()}<svg viewBox="0 0 24 24" data-testid="icon"><rect x="3" y="3" width="8" height="8" /></svg
  >{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="padding: var(--t-space-16)">
    <SegmentedControl
      bind:value
      label="View"
      {expand}
      options={[
        { value: 'list', label: long ? 'Overview' : 'List' },
        { value: 'grid', label: 'Grid', icon: icons ? gridIcon : undefined },
        { value: 'map', label: long ? 'Notifications' : 'Map' },
        ...(long ? [{ value: 'more', label: 'Quarterly' }] : []),
      ]}
    />
  </div>
</TsuyaProvider>
