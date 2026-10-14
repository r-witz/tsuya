<!--
  @component
  A region in the accent of a pair (DESIGN.md, Accent): it and everything inside take the pair's colour for the
  nearest mode, and a change of pair cross-fades. Rendered on the server.
-->
<script lang="ts">
  import { fadeAccent, shownAccent, type RegionPair } from '@tsuya/core';
  import { untrack, type Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The pair, from the engine; null for the accent around the region. */
    pair: RegionPair | null;
    /** The region's element. */
    ref?: HTMLDivElement | null;
    /** What the accent applies to. */
    children?: Snippet;
  }

  let { pair, ref = $bindable(null), class: className, children, ...rest }: Props = $props();

  // what the region shows before a new pair is written, read first, so that the new pair cross-fades from there
  let shown: RegionPair | null = untrack(() => pair);
  let before: RegionPair | null = null;
  // the region keeps its class while it fades back to the accent around it
  let leaving = $state(false);

  $effect.pre(() => {
    if (pair === shown) return;
    shown = pair;
    const node = untrack(() => ref);
    before = node && shownAccent(node);
  });

  $effect(() => {
    const next = pair;
    const node = untrack(() => ref);
    const from = before;
    before = null;
    if (!node || !from) return;
    leaving = next === null;
    // to the pair, or back to the accent around the region; the fade stops with the effect
    return fadeAccent(node, from, next ?? (node.parentElement && shownAccent(node.parentElement)), () => {
      for (const mode of ['light', 'dark'] as const) {
        if (next) node.style.setProperty(`--t-accent-${mode}`, next[mode]);
        else node.style.removeProperty(`--t-accent-${mode}`);
      }
      leaving = false;
    });
  });
</script>

<div
  bind:this={ref}
  {...rest}
  class={[(pair || leaving) && 't-accent', className]}
  style:--t-accent-light={pair?.light}
  style:--t-accent-dark={pair?.dark}
  data-accent={pair?.seed === null ? 'neutral' : undefined}
>
  {@render children?.()}
</div>
