<!--
  @component
  A loading placeholder (DESIGN.md, Skeleton): a block of `fill-strong` at the final size of what loads, with the
  radius of the real element, and a slow opacity pulse (0.5 to 1, 1.6 s) that stops under reduced motion. Hidden
  from screen readers: the region that loads, which holds it, is `aria-busy`.
-->
<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** In px, or any CSS length. Default 100%. */
    width?: number | string;
    /** In px, or any CSS length. Default 1em. */
    height?: number | string;
    /** The radius of the real element it stands in for. Default 'xs'. */
    radius?: 'xs' | 'sm' | 'md' | 'lg' | 'full' | number;
    /** The element. */
    ref?: HTMLDivElement | null;
  }

  let { width, height, radius = 'xs', ref = $bindable(null), class: className, ...rest }: Props = $props();

  const length = (value: number | string | undefined) => (typeof value === 'number' ? `${String(value)}px` : value);
  const borderRadius = $derived(typeof radius === 'number' ? `${String(radius)}px` : `var(--t-radius-${radius})`);
</script>

<div
  bind:this={ref}
  {...rest}
  class={['t-skeleton', className]}
  style:width={length(width)}
  style:height={length(height)}
  style:border-radius={borderRadius}
  aria-hidden="true"
></div>
