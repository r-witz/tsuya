<!--
  @component
  The row of tabs (DESIGN.md, Tabs): one tab stop, arrows in visual order, Home and End; it scrolls sideways when the
  tabs do not fit. The bar under the selected tab slides to the next one over `--t-duration-fast`.
-->
<script lang="ts">
  import { rovingFocus } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { duration } from '../../primitives/motion.svelte.ts';
  import { getTabs } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The row. */
    ref?: HTMLDivElement | null;
    /** Its triggers. */
    children: Snippet;
  }

  let { ref = $bindable(null), class: className, children, ...rest }: Props = $props();

  const tabs = getTabs('List');
  // the bar of the tab selected before a change: when the value changes, the DOM still shows the old one
  let before: DOMRect | undefined;
  $effect.pre(() => {
    if (tabs.value !== undefined) {
      before = ref?.querySelector('[role="tab"][aria-selected="true"]')?.getBoundingClientRect();
    }
  });

  // then the bar of the new tab starts where the old one was
  $effect(() => {
    const value = tabs.value;
    const tab = value === undefined ? null : document.getElementById(tabs.tabId(value));
    const ms = tab ? duration(tab, 'fast') : 0;
    if (!tab || !before || !ms) return;
    const after = tab.getBoundingClientRect();
    if (after.width === 0 || (after.left === before.left && after.width === before.width)) return;
    tab.animate(
      [{ translate: `${String(before.left - after.left)}px 0`, scale: `${String(before.width / after.width)} 1` }, {}],
      {
        duration: ms,
        easing: getComputedStyle(tab).getPropertyValue('--t-easing-standard').trim() || 'ease',
        pseudoElement: '::before',
      },
    );
  });
</script>

<div
  bind:this={ref}
  {...rest}
  role="tablist"
  aria-orientation="horizontal"
  class={['t-tabs-list', className]}
  {@attach rovingFocus({
    items: '[role="tab"]',
    orientation: 'horizontal',
    onmove: (tab) => {
      const value = tab.dataset['value'];
      if (!tabs.props.manual() && value !== undefined) tabs.select(value);
    },
  })}
>
  {@render children()}
</div>
