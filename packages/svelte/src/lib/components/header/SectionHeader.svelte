<!--
  @component
  A section's header (DESIGN.md, PageHeader, SectionHeader): a title, an optional count, and a ghost "see all"
  button at the end.
-->
<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  import Button from '../button/Button.svelte';

  interface Props extends Omit<HTMLAttributes<HTMLElement>, 'children' | 'title'> {
    /** The title. */
    title: string;
    /** A count shown beside the title. */
    count?: string;
    /** A ghost button at the end, such as "See all". */
    action?: { label: string; onclick?: () => void; href?: string };
    /** The header's element. */
    ref?: HTMLElement | null;
  }

  let { title, count, action, ref = $bindable(null), class: className, ...rest }: Props = $props();
</script>

<div bind:this={ref} {...rest} class={['t-section-header', className]}>
  <h2 class="t-section-header-title">{title}</h2>
  {#if count}<span class="t-section-header-count">{count}</span>{/if}
  {#if action}
    <Button variant="ghost" size="sm" href={action.href} onclick={action.onclick}>{action.label}</Button>
  {/if}
</div>
