<!--
  @component
  A badge (DESIGN.md, Badge): a count pill ("99+" above 99) or a dot, meant to be pinned on the corner of a host
  (an icon button, an avatar) through its `badge` prop. Decorative: the badge's meaning belongs to the host's
  accessible name, not to the badge itself.
-->
<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLAttributes<HTMLSpanElement>, 'children'> {
    /** "99+" above 99. */
    count?: number;
    /** A plain dot instead of a count. */
    dot?: boolean;
    /** The element. */
    ref?: HTMLSpanElement | null;
  }

  let { count, dot = false, ref = $bindable(null), class: className, ...rest }: Props = $props();

  const text = $derived(count === undefined ? undefined : count > 99 ? '99+' : String(count));
</script>

{#if dot}
  <span bind:this={ref} {...rest} class={['t-badge', 't-badge-dot', className]} aria-hidden="true"></span>
{:else if text !== undefined}
  <span bind:this={ref} {...rest} class={['t-badge', 't-badge-count', className]} aria-hidden="true">{text}</span>
{/if}
