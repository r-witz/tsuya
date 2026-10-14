<!-- A toast, with or without an icon and an action; a dialog alongside it, for the top layer order; a phone screen
     with a tab bar in its dock, for the toast to clear. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import {
    Button,
    Dialog,
    Screen,
    TabBar,
    TsuyaProvider,
    toast,
    type ToastIcon,
  } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    message?: string;
    icon?: ToastIcon;
    withAction?: boolean;
    dir?: 'ltr' | 'rtl';
    onaction?: () => void;
    tabBar?: boolean;
  }

  let {
    message = 'Saved',
    icon,
    withAction = false,
    dir = 'ltr',
    onaction = () => {},
    tabBar = false,
  }: Props = $props();

  let dialogOpen = $state(false);
</script>

{#snippet glyph()}<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="8" /></svg>{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="padding: var(--t-space-16)">
    <Button
      onclick={() => {
        toast(message, { icon, action: withAction ? { label: 'Undo', onclick: onaction } : undefined });
      }}>Notify</Button
    >
    <Button
      onclick={() => {
        toast('Also saved');
      }}>Notify again</Button
    >
    <Dialog.Root bind:open={dialogOpen}>
      <Dialog.Trigger>
        {#snippet children(props)}<Button {...props}>Open dialog</Button>{/snippet}
      </Dialog.Trigger>
      <Dialog.Content data-testid="dialog">
        <Dialog.Title>A dialog</Dialog.Title>
        <Button
          onclick={() => {
            toast('Saved', { icon });
          }}>Notify from dialog</Button
        >
        <Dialog.Actions>
          <Dialog.Close>
            {#snippet children(props)}<Button {...props}>Close</Button>{/snippet}
          </Dialog.Close>
        </Dialog.Actions>
      </Dialog.Content>
    </Dialog.Root>
  </div>
  {#if tabBar}
    <Screen>
      <p>Library</p>
      {#snippet dock()}
        <TabBar
          aria-label="Sections"
          items={[
            { value: 'home', label: 'Home', icon: glyph },
            { value: 'library', label: 'Library', icon: glyph },
            { value: 'settings', label: 'Settings', icon: glyph },
          ]}
        />
      {/snippet}
    </Screen>
  {/if}
</TsuyaProvider>
