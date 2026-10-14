<!--
  @component
  A progress bar (DESIGN.md, Progress): a native `<progress>`, the track filled with the accent; a thin variant (2)
  for along an edge. Without a value a third of the bar sweeps across the track every 1.2 s (right to left in a
  right-to-left page), its motion kept under reduced motion since it is the information. Named, with its value
  through the progress bar role.
-->
<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  import { getLabels } from '../../primitives/labels.ts';

  interface Props extends Omit<HTMLAttributes<HTMLProgressElement>, 'children'> {
    /** The completed share, 0 to `max`; indeterminate when left out. */
    value?: number;
    /** The value that is complete. Default 1. */
    max?: number;
    /** What is loading; the `loading` label by default. */
    label?: string;
    /** 2 tall, for along an edge. */
    thin?: boolean;
    /** The element. */
    ref?: HTMLProgressElement | null;
  }

  let { value, max = 1, label, thin = false, ref = $bindable(null), class: className, ...rest }: Props = $props();

  const labels = getLabels('Progress');
  const classes = $derived(['t-progress', thin && 't-progress-thin', className]);
</script>

<!-- two branches, not one `value={value}`: a `<progress>` that Svelte gives a value of `undefined` still gets its
     value property set to 0, which keeps it determinate instead of indeterminate -->
{#if value === undefined}
  <progress bind:this={ref} {...rest} {max} aria-label={label ?? labels.loading} class={classes}></progress>
{:else}
  <progress bind:this={ref} {...rest} {value} {max} aria-label={label ?? labels.loading} class={classes}></progress>
{/if}
