<!--
  @component
  A group of sidebar items (DESIGN.md, Sidebar) under its label in `--t-type-label`; collapsed, the label is read only.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { getCollapsed } from './state.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The group's heading. */
    label: string;
    /** Its items. */
    children: Snippet;
  }

  let { label, class: className, children, ...rest }: Props = $props();

  const id = $props.id();
  const collapsed = getCollapsed();
</script>

<div {...rest} role="group" aria-labelledby={id} class={['t-sidebar-group', className]}>
  <p class={['t-label', 't-sidebar-group-heading', collapsed() && 't-sidebar-group-read-only']} {id}>{label}</p>
  {@render children()}
</div>
