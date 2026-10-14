<!-- Filters in a popover from a button, details in one from an icon button at the end of the row. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, Checkbox, IconButton, Popover, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    open?: boolean;
    dir?: 'ltr' | 'rtl';
  }

  let { open = $bindable(false), dir = 'ltr' }: Props = $props();

  let unread = $state(false);
</script>

{#snippet info()}<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9" /></svg>{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="display: flex; justify-content: space-between; padding: var(--t-space-16)">
    <Popover.Root bind:open>
      <Popover.Trigger>Filters</Popover.Trigger>
      <Popover.Content>
        <div style="display: flex; flex-direction: column; gap: var(--t-space-8)">
          <Checkbox bind:checked={unread}>Unread only</Checkbox>
          <Button
            variant="primary"
            onclick={() => {
              open = false;
            }}>Apply</Button
          >
        </div>
      </Popover.Content>
    </Popover.Root>
    <Popover.Root>
      <Popover.Trigger>
        {#snippet child(props)}<IconButton {...props} label="Details" icon={info} />{/snippet}
      </Popover.Trigger>
      <Popover.Content align="end">Added on 12 October, from the web.</Popover.Content>
    </Popover.Root>
  </div>
  <div style="display: flex; justify-content: center; padding: var(--t-space-16)"><Button>After</Button></div>
  <output data-testid="unread">{String(unread)}</output>
</TsuyaProvider>
