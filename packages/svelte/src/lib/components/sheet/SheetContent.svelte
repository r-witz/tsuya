<!--
  @component
  The sheet's box (DESIGN.md, Sheet): a native `<dialog>` shown with `showModal()`, the focus scope primitive for its
  trap and its restore to the opener. Bottom: at most `tablet` wide, top corners `radius-lg`, padding `space-24` (top
  `space-12` above a `space-32` by `space-4` handle), `space-32` plus the safe area below, at most the viewport height
  minus `space-48`. `side="end"`: 400 wide at most, full height, from the end edge (mirrors in RTL). Surface with a hairline
  and `shadow-lg`, or glass when it opens from glass. Slides over `duration-sheet` with `easing-emphasized`; nothing
  moves under reduced motion. Escape, a press on the scrim, or (bottom, on touch) a drag down past a third of its
  height or a fling, close it.
-->
<script lang="ts">
  import { modal, swipeDown } from '@tsuya/core/primitives';
  import { flushSync, type Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { getSheet } from './state.svelte.ts';

  interface Props extends Omit<HTMLAttributes<HTMLDialogElement>, 'children'> {
    /** The dialog element. */
    ref?: HTMLDialogElement | null;
    /** The title and the body. */
    children?: Snippet;
  }

  let { ref = $bindable(null), class: className, children, ...rest }: Props = $props();

  const sheet = getSheet('Content');
  const side = $derived(sheet.props.side());
  // the surface that opens it: still its ancestor, even shown in the top layer (DESIGN.md, Glass)
  const glass = $derived(Boolean(ref?.closest('.t-glass, .t-glass-control')));
</script>

<dialog
  bind:this={ref}
  {...rest}
  aria-labelledby={sheet.title.idref}
  class={['t-sheet', `t-sheet-${side}`, glass && 't-glass', className]}
  data-shadow={glass ? 'lg' : undefined}
  {@attach sheet.open &&
    modal(() => {
      sheet.close();
    })}
>
  {#if side === 'bottom'}
    <div
      class="t-sheet-handle-row"
      aria-hidden="true"
      {@attach swipeDown({
        target: () => ref,
        ondismiss: () => {
          sheet.close();
          flushSync();
        },
      })}
    >
      <div class="t-sheet-handle"></div>
    </div>
  {/if}
  <div class="t-sheet-body">
    {@render children?.()}
  </div>
</dialog>
