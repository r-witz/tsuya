<!--
  @component
  An option of a listbox (DESIGN.md, Select, Combobox): a row with its label, ticked when selected, filled while
  active. Select.Item and Combobox render it.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Glyph from './Glyph.svelte';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    selected: boolean;
    active: boolean;
    disabled?: boolean;
    ref?: HTMLElement | null;
    children: Snippet;
  }

  let {
    selected,
    active,
    disabled = false,
    ref = $bindable(null),
    class: className,
    children,
    ...rest
  }: Props = $props();
</script>

<div
  bind:this={ref}
  {...rest}
  role="option"
  aria-selected={selected}
  aria-disabled={disabled || undefined}
  class={['t-option', active && 't-option-active', className]}
>
  <span class="t-option-label">{@render children()}</span>
  {#if selected}<Glyph name="check" />{/if}
</div>
