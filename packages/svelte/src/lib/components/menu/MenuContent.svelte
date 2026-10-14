<!--
  @component
  The panel of a menu (DESIGN.md, Menu): under its opener aligned to its end edge, above when there is no room; glass
  when opened from glass unless it holds a destructive item. As it opens, focus goes to the first item (the last from
  the up arrow); arrows wrap, Home, End and letters move. Escape closes it and focus goes back to the opener; Tab and
  a press outside close it.
-->
<script lang="ts">
  import { rovingFocus, type Align, type Side } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Panel from '../../internal/Panel.svelte';
  import { getMenu } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The side of the trigger it opens on. */
    side?: Side;
    /** How it aligns along that side. */
    align?: Align;
    /** The panel. */
    ref?: HTMLDivElement | null;
    /** Its items. */
    children: Snippet;
  }

  let { side = 'bottom', align = 'end', ref = $bindable(null), class: className, children, ...rest }: Props = $props();

  const menu = getMenu('Content');
  const ITEMS = '[role^="menuitem"]';

  $effect(() => {
    if (!menu.open) return;
    const from = menu.from;
    // once the update that opens it is over, the panel shows and its items can take focus
    queueMicrotask(() => {
      const items = ref ? [...ref.querySelectorAll<HTMLElement>(ITEMS)] : [];
      (from === 'last' ? items.at(-1) : items[0])?.focus();
    });
  });
</script>

<Panel
  bind:ref
  {...rest}
  open={menu.open}
  anchor={() => menu.trigger}
  {side}
  {align}
  solid={menu.destructive > 0}
  ondismiss={(reason) => {
    menu.close(reason === 'escape');
  }}
  id={menu.contentId}
  role="menu"
  aria-labelledby={menu.triggerId}
  class={['t-menu', className]}
  {@attach rovingFocus({ items: ITEMS, orientation: 'vertical', typeahead: true, disabledFocusable: true })}
>
  {@render children()}
</Panel>
