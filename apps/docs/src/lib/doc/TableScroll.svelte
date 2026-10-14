<!--
  A wide table scrolls sideways inside its own box instead of pushing the page's column wider or being clipped
  (WCAG 1.4.10, reflow). A scrolling region has to be reachable by keyboard and named (WCAG 2.1.1, axe's
  scrollable-region-focusable), so it takes a tab stop and a name only while it actually overflows.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  interface Props {
    /** What the table is, for the name of the region when it scrolls ("Props"). */
    label: string;
    children: Snippet;
  }

  let { label, children }: Props = $props();

  let scrolls = $state(false);

  const watch = (box: HTMLElement) => {
    const measure = () => {
      scrolls = box.scrollWidth > box.clientWidth;
    };
    const observer = new ResizeObserver(measure);
    observer.observe(box);
    if (box.firstElementChild) observer.observe(box.firstElementChild);
    return () => {
      observer.disconnect();
    };
  };
</script>

<!-- a region that scrolls has to be reachable by keyboard, and is named: its tab stop is on purpose -->
<!-- svelte-ignore a11y_no_noninteractive_tabindex -->
<div
  class="scroll"
  role={scrolls ? 'group' : undefined}
  aria-label={scrolls ? label : undefined}
  tabindex={scrolls ? 0 : undefined}
  {@attach watch}
>
  {@render children()}
</div>

<style>
  .scroll {
    overflow-x: auto;
    max-width: 100%;
  }
  .scroll:focus-visible {
    outline: var(--t-state-focus-width) solid var(--t-accent);
    outline-offset: var(--t-state-focus-offset);
  }
</style>
