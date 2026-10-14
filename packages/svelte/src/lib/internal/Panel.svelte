<!--
  @component
  The panel of a menu, a select's listbox or a popover (DESIGN.md, Menu): anchored to its trigger in the top layer,
  where it stays in the document so that it keeps the accent and labels around it. `--t-surface` with a hairline and
  `--t-shadow-lg`, or glass when its trigger sits on glass. Always rendered, shown while `open`; it fades in and out
  (at once under reduced motion). Escape, a press outside and focus leaving ask it to close.
-->
<script lang="ts">
  import { anchored, dismissable, type Align, type DismissReason, type Side } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    open: boolean;
    /** The trigger. */
    anchor: () => HTMLElement | null | undefined;
    side?: Side;
    align?: Align;
    ondismiss: (reason: DismissReason) => void;
    /** Close when focus leaves; false while focus stays on the trigger, as in a select. Default true. */
    focusOutside?: boolean;
    /** Never glass, as a menu that holds a destructive item. */
    solid?: boolean;
    /** Padding --t-space-16, for content rather than items, as in a popover. */
    padded?: boolean;
    ref?: HTMLDivElement | null;
    children?: Snippet;
  }

  let {
    open,
    anchor,
    side,
    align,
    ondismiss,
    focusOutside = true,
    solid = false,
    padded = false,
    ref = $bindable(null),
    class: className,
    children,
    ...rest
  }: Props = $props();

  // glass when opened from glass, measured as it opens
  const glass = $derived(!solid && open && Boolean(anchor()?.closest('.t-glass, .t-glass-control')));

  $effect(() => {
    if (!ref) return;
    if (open && !ref.matches(':popover-open')) ref.showPopover();
    else if (!open && ref.matches(':popover-open')) ref.hidePopover();
  });
</script>

<div
  bind:this={ref}
  {...rest}
  popover="manual"
  class={['t-panel', glass && 't-glass', padded && 't-panel-padded', className]}
  data-shadow={glass ? 'lg' : undefined}
  style:--_t-anchor-width={open ? `${String(anchor()?.offsetWidth ?? 0)}px` : undefined}
  {@attach open && anchored({ anchor, side, align })}
  {@attach open && dismissable({ ondismiss, inside: () => [anchor()], focusOutside })}
>
  {@render children?.()}
</div>
