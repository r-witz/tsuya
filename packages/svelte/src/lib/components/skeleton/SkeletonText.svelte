<!--
  @component
  Lines of skeleton text (DESIGN.md, Skeleton): `lines` rows at a text line's height, the last one shorter so it
  reads like a paragraph. Hidden from screen readers: the region that loads, which holds it, is `aria-busy`.
-->
<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  import Skeleton from './Skeleton.svelte';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** Default 3. */
    lines?: number;
    /** The element. */
    ref?: HTMLDivElement | null;
  }

  let { lines = 3, ref = $bindable(null), class: className, ...rest }: Props = $props();
</script>

<div bind:this={ref} {...rest} class={['t-skeleton-text', className]} aria-hidden="true">
  {#each Array.from({ length: lines }, (_, i) => i) as i (i)}
    <Skeleton width={i === lines - 1 && lines > 1 ? '60%' : '100%'} />
  {/each}
</div>
