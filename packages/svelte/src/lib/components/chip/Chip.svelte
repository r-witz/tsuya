<!--
  @component
  A chip (DESIGN.md, Chip): a filter or sort option, a pressable pill-ish token with an optional icon; selected turns
  it accent-filled. Standalone it is a toggle button (`selected`, `onclick`); inside a <ChipGroup> it takes the
  group's radio or toggle-button semantics instead, and `value` identifies it to the group.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLButtonAttributes } from 'svelte/elements';

  import { getChipGroup } from './chip-group-context.ts';

  interface Props extends Omit<HTMLButtonAttributes, 'children' | 'value' | 'aria-pressed' | 'aria-checked'> {
    /** Identifies the chip inside a ChipGroup. */
    value?: string;
    /** Ignored inside a ChipGroup, which drives selection itself. */
    selected?: boolean;
    /** Control glass, over artwork. */
    glass?: boolean;
    /** Called when it is pressed. */
    onclick?: (event: MouseEvent) => void;
    /** An icon before the label. */
    icon?: Snippet;
    /** The label. */
    children?: Snippet;
    /** The button. */
    ref?: HTMLButtonElement | null;
  }

  let {
    value,
    selected = false,
    glass = false,
    onclick,
    icon,
    children,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  const group = getChipGroup();
  const asRadio = $derived(group !== undefined && !group.multiple);
  const checked = $derived(group ? group.isSelected(value) : selected);
</script>

<button
  bind:this={ref}
  {...rest}
  type="button"
  class={['t-chip', 't-pressable', glass && 't-glass-control', className]}
  role={asRadio ? 'radio' : undefined}
  aria-checked={asRadio ? checked : undefined}
  aria-pressed={asRadio ? undefined : checked}
  onclick={(event) => {
    group?.toggle(value);
    onclick?.(event);
  }}
>
  {#if icon}{@render icon()}{/if}
  {#if children}{@render children()}{/if}
</button>
