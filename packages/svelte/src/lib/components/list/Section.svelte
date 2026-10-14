<!--
  @component
  A labelled group of rows in a List (DESIGN.md, List, ListItem, Section): a label above its rows.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** The heading of the section. */
    label: string;
    /** Its rows. */
    children: Snippet;
    /** The group's element. */
    ref?: HTMLDivElement | null;
  }

  let { label, children, ref = $bindable(null), class: className, ...rest }: Props = $props();

  const id = $props.id();
</script>

<div bind:this={ref} {...rest} role="group" aria-labelledby={id} class={['t-section', className]}>
  <div class="t-label t-section-label" {id}>{label}</div>
  {@render children()}
</div>
