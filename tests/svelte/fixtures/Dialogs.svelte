<!-- A dialog that deletes a photo, opened by its own trigger; a not-dismissible and an alertdialog variant. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, Dialog, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    open?: boolean;
    dismissible?: boolean;
    alert?: boolean;
    size?: 'md' | 'lg';
    autofocusPrimary?: boolean;
    dir?: 'ltr' | 'rtl';
    onconfirm?: () => void;
  }

  let {
    open = $bindable(false),
    dismissible = true,
    alert = false,
    size = 'md',
    autofocusPrimary = false,
    dir = 'ltr',
    onconfirm = () => {},
  }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="padding: var(--t-space-16)">
    <Dialog.Root bind:open {dismissible} {alert}>
      <Dialog.Trigger>
        {#snippet children(props)}<Button {...props}>Delete photo</Button>{/snippet}
      </Dialog.Trigger>
      <Dialog.Content {size} data-testid="content">
        <Dialog.Title>Delete this photo?</Dialog.Title>
        <Dialog.Description>This cannot be undone.</Dialog.Description>
        <Dialog.Actions>
          <Dialog.Close>
            {#snippet children(props)}<Button variant="secondary" {...props}>Cancel</Button>{/snippet}
          </Dialog.Close>
          <Button
            variant="danger"
            autofocus={autofocusPrimary ? true : undefined}
            onclick={() => {
              onconfirm();
              open = false;
            }}>Delete</Button
          >
        </Dialog.Actions>
      </Dialog.Content>
    </Dialog.Root>
  </div>
</TsuyaProvider>
