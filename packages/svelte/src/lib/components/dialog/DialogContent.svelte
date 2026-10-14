<!--
  @component
  The dialog's box (DESIGN.md, Dialog): a native `<dialog>` shown with `showModal()`, for its top layer and its
  `::backdrop`; the focus scope primitive traps Tab, gives initial focus (Dialog.Close by default: the least
  destructive action, unless an action marks its own `autofocus`) and restores it to the opener on close. At most 420
  wide (`size="lg"`: 560), `space-16` from the screen edges, `radius-lg`, padding `space-24`, surface with a hairline
  and `shadow-lg`, over the scrim. Fades and grows from 0.98 over `base`; nothing moves under reduced motion. Escape
  and a press on the scrim ask to close (Dialog.Root's `dismissible`).
-->
<script lang="ts">
  import { modal } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { getDialog } from './state.svelte.ts';

  interface Props extends Omit<HTMLAttributes<HTMLDialogElement>, 'children'> {
    /** 560 wide instead of 420. Default 'md'. */
    size?: 'md' | 'lg';
    /** The dialog element. */
    ref?: HTMLDialogElement | null;
    /** The title, description, body and actions. */
    children?: Snippet;
  }

  let { size = 'md', ref = $bindable(null), class: className, children, ...rest }: Props = $props();

  const dialog = getDialog('Content');

  // the focus scope's own initial focus is a no-op here (showModal already focused something inside it); correct
  // that native choice to Dialog.Close, unless the consumer marked an action of their own with autofocus
  $effect(() => {
    if (!dialog.open) return;
    const node = ref;
    if (!node) return;
    queueMicrotask(() => {
      if (!node.isConnected || node.querySelector('[autofocus]')) return;
      node.querySelector<HTMLElement>('[data-tsuya-dialog-close]')?.focus();
    });
  });
</script>

<dialog
  bind:this={ref}
  {...rest}
  role={dialog.props.alert() ? 'alertdialog' : undefined}
  aria-labelledby={dialog.title.idref}
  aria-describedby={dialog.description.idref}
  class={['t-dialog', `t-dialog-${size}`, className]}
  closedby={dialog.props.dismissible() ? undefined : 'none'}
  oncancel={(event) => {
    // a close request the browser makes itself (Escape, Android back) where closedby is not supported
    if (!dialog.props.dismissible()) event.preventDefault();
  }}
  {@attach dialog.open &&
    modal(() => {
      dialog.dismiss();
    })}
>
  {@render children?.()}
</dialog>
