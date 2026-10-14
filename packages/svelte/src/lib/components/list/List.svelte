<!--
  @component
  A list of rows (DESIGN.md, List, ListItem, Section): full-width, no card, its ListItem rows separated by
  hairlines, optionally grouped into Sections.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** Its items. */
    children: Snippet;
    /** The list's element. */
    ref?: HTMLDivElement | null;
  }

  let { children, ref = $bindable(null), class: className, ...rest }: Props = $props();
</script>

<div bind:this={ref} {...rest} class={['t-list', className]}>
  {@render children()}
</div>
