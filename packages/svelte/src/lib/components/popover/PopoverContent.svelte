<!--
  @component
  The panel of a popover (DESIGN.md, Popover): small interactive content (filters, a colour picker, details) anchored
  to its opener, the menu's panel with padding --t-space-16, named by its opener. Opened from the keyboard, focus moves
  to its first control, or to the panel. Escape closes it and focus goes back to the opener; a press outside and focus
  leaving close it.
-->
<script lang="ts">
  import { tabbables, type Align, type Side } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Panel from '../../internal/Panel.svelte';
  import { getPopover } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The side of the trigger it opens on. */
    side?: Side;
    /** How it aligns along that side. */
    align?: Align;
    /** The panel. */
    ref?: HTMLDivElement | null;
    /** Its content. */
    children: Snippet;
  }

  let {
    side = 'bottom',
    align = 'start',
    ref = $bindable(null),
    class: className,
    children,
    ...rest
  }: Props = $props();

  const popover = getPopover('Content');

  $effect(() => {
    if (!popover.open || !popover.byKeyboard) return;
    // once the update that opens it is over, the panel shows and can take focus
    queueMicrotask(() => {
      if (ref) (tabbables(ref)[0] ?? ref).focus();
    });
  });
</script>

<Panel
  bind:ref
  aria-labelledby={popover.triggerId}
  {...rest}
  open={popover.open}
  anchor={() => popover.trigger}
  {side}
  {align}
  ondismiss={(reason) => {
    popover.close(reason === 'escape');
  }}
  id={popover.contentId}
  role="dialog"
  tabindex={-1}
  padded
  class={['t-popover', className]}
>
  {@render children()}
</Panel>
