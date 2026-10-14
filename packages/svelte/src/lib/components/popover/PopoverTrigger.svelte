<!--
  @component
  The opener of a popover (DESIGN.md, Popover): a secondary button, or your own element through `child` (an icon
  button), spreading the props it receives. A press toggles the popover; from the keyboard, focus moves into it.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import { createAttachmentKey } from 'svelte/attachments';

  import Opener from '../../internal/Opener.svelte';
  import type { ButtonProps } from '../button/types.ts';
  import { getPopover } from './state.svelte.ts';

  type Props = Omit<ButtonProps, 'onclick'> & {
    /** Your own opener; spread the props it receives on its element. */
    child?: Snippet<[Record<string | symbol, unknown>]>;
  };

  let { child, children, ...rest }: Props = $props();

  const popover = getPopover('Trigger');
  const key = createAttachmentKey();

  // one function, so that the opener stays attached while its props change
  function attach(node: HTMLElement) {
    popover.trigger = node;
    return () => {
      if (popover.trigger === node) popover.trigger = null;
    };
  }

  const opener = $derived({
    id: popover.triggerId,
    'aria-haspopup': 'dialog',
    'aria-expanded': popover.open,
    'aria-controls': popover.contentId,
    // a click from Enter or Space has no pointer, and no count of presses
    onclick: (event: MouseEvent) => {
      if (popover.open) popover.close();
      else popover.show(event.detail === 0);
    },
    [key]: attach,
  });
</script>

<Opener {...rest} {opener} {child} {children} />
