<!--
  @component
  The tab bar of the phone shell (DESIGN.md, TabBar, Screen): glass, at least --t-size-dock tall, --t-radius-lg, 3 to
  5 items sharing its width, each an icon 24 over a --t-type-micro label in --t-text-muted; the current one has its
  icon in the accent, its label in --t-text at 700 and a --t-fill-strong capsule behind it. A badge is pinned to an
  icon, its meaning read after the label. One tab stop: arrows move, Enter and Space choose; a press on the current
  tab scrolls the page (or its scroll container) to the top. Put it in the `dock` of a Screen, which floats it.
-->
<script lang="ts" module>
  import { HIDDEN, rovingFocus } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';

  export interface TabBarItem {
    /** Identifies the tab in the bar's `value`. */
    value: string;
    /** The text under the icon. */
    label: string;
    /** The icon, 24 square. */
    icon: Snippet;
    /** Pinned to the icon: a count or a dot, and what it means, read after the label ("3 new"). */
    badge?: { count?: number; dot?: boolean; label: string };
  }
</script>

<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  import Badge from '../badge/Badge.svelte';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** The current tab; the first while there is none. */
    value?: string;
    /** The 3 to 5 tabs. */
    items: TabBarItem[];
    /** The bar. */
    ref?: HTMLDivElement | null;
  }

  let { value = $bindable(), items, ref = $bindable(null), class: className, ...rest }: Props = $props();

  const current = $derived(value ?? items[0]?.value);

  function choose(item: TabBarItem) {
    if (item.value !== current) {
      value = item.value;
      return;
    }
    const still = matchMedia('(prefers-reduced-motion: reduce)').matches;
    // the nearest scroll container the tab bar is in, the window when the page itself scrolls
    let scroller: Element | null = ref?.parentElement ?? null;
    while (
      scroller &&
      !(/auto|scroll/.test(getComputedStyle(scroller).overflowY) && scroller.scrollHeight > scroller.clientHeight)
    ) {
      scroller = scroller.parentElement;
    }
    (scroller ?? window).scrollTo({ top: 0, behavior: still ? 'instant' : 'smooth' });
  }
</script>

<div
  bind:this={ref}
  {...rest}
  role="tablist"
  class={['t-tab-bar', 't-glass', className]}
  {@attach rovingFocus({ items: '[role="tab"]', orientation: 'horizontal' })}
>
  {#each items as item (item.value)}
    <button
      type="button"
      role="tab"
      aria-selected={item.value === current}
      class="t-tab-bar-item t-pressable"
      onclick={() => {
        choose(item);
      }}
    >
      <span class="t-tab-bar-icon">
        {@render item.icon()}
        {#if item.badge}
          <span class="t-tab-bar-pin"><Badge count={item.badge.count} dot={item.badge.dot} /></span>
        {/if}
      </span>
      <!-- the badge's meaning in the content, not an aria-label, which would leave out the count it shows -->
      <span class="t-tab-bar-label"
        >{item.label}{#if item.badge}<span style={HIDDEN}>, {item.badge.label}</span>{/if}</span
      >
    </button>
  {/each}
</div>
