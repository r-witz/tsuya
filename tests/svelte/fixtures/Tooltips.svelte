<!-- A button with a tooltip, an icon button whose label shows as one, and an icon button without; a select, and an
     icon button with its tooltip in a popover, to share the Escape key with. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import {
    Button,
    IconButton,
    Popover,
    Select,
    TsuyaProvider,
    Tooltip,
  } from '../../../packages/svelte/src/lib/index.ts';
</script>

{#snippet star()}<svg viewBox="0 0 24 24"><path d="M12 3l3 6 6 1-4 4 1 6-6-3-6 3 1-6-4-4 6-1z" /></svg>{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div style="display: flex; gap: var(--t-space-16); padding: 120px var(--t-space-16)">
    <Button>Before</Button>
    <Tooltip text="Copies the address of this page">
      {#snippet trigger(props)}<Button {...props}>Copy link</Button>{/snippet}
    </Tooltip>
    <IconButton label="Share" icon={star} />
    <IconButton label="Shuffle" icon={star} tooltip={false} />
  </div>
  <div style="display: flex; gap: var(--t-space-16); padding: 0 var(--t-space-16)">
    <Select label="Country" options={[{ value: 'FR', label: 'France' }]} />
    <Popover.Root>
      <Popover.Trigger>Share options</Popover.Trigger>
      <Popover.Content><IconButton label="Copy" icon={star} /></Popover.Content>
    </Popover.Root>
  </div>
</TsuyaProvider>
