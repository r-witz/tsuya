<!--
  @component
  A surface (DESIGN.md, Surface): a positioned, isolated region that lays out, back to front, its background, an
  Ambient or a Glow placed inside it, the grain, then the content.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The grain: over the background (`bg`), over the content too for poster-like pages (`all`), or `off`. */
    grain?: 'bg' | 'all' | 'off';
    /** The surface's element. */
    ref?: HTMLDivElement | null;
    /** Its content. */
    children?: Snippet;
  }

  let { grain = 'bg', ref = $bindable(null), class: className, children, ...rest }: Props = $props();
</script>

<div bind:this={ref} {...rest} class={['t-surface', className]} data-grain={grain === 'bg' ? undefined : grain}>
  {@render children?.()}
</div>
