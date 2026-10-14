<!--
  @component
  The opener of a menu (DESIGN.md, Menu): a secondary button, or your own element through `child` (an icon button),
  spreading the props it receives. A press, Enter or Space opens the menu on its first item, the up arrow on its last.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import { createAttachmentKey } from 'svelte/attachments';

  import Opener from '../../internal/Opener.svelte';
  import type { ButtonProps } from '../button/types.ts';
  import { getMenu } from './state.svelte.ts';

  type Props = Omit<ButtonProps, 'onclick'> & {
    /** Your own opener; spread the props it receives on its element. */
    child?: Snippet<[Record<string | symbol, unknown>]>;
  };

  let { child, children, ...rest }: Props = $props();

  const menu = getMenu('Trigger');
  const key = createAttachmentKey();

  // one function, so that the opener stays attached while its props change
  function attach(node: HTMLElement) {
    menu.trigger = node;
    return () => {
      if (menu.trigger === node) menu.trigger = null;
    };
  }

  const opener = $derived({
    id: menu.triggerId,
    'aria-haspopup': 'menu',
    'aria-expanded': menu.open,
    'aria-controls': menu.contentId,
    onclick: () => {
      if (menu.open) menu.close();
      else menu.show();
    },
    onkeydown: (event: KeyboardEvent) => {
      if (menu.open || (event.key !== 'ArrowDown' && event.key !== 'ArrowUp')) return;
      event.preventDefault();
      menu.show(event.key === 'ArrowUp' ? 'last' : 'first');
    },
    [key]: attach,
  });
</script>

<Opener {...rest} {opener} {child} {children} />
