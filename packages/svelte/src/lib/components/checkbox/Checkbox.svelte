<!--
  @component
  A checkbox (DESIGN.md, Checkbox): a native input drawn as a 20 box that fills with the accent and a tick when
  checked, a dash when indeterminate. With its label the whole row is pressable and at least target tall; the focus
  ring sits on the box, around the hidden native input.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLInputAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';

  interface Props extends Omit<HTMLInputAttributes, 'type' | 'checked' | 'children'> {
    /** Whether it is checked. */
    checked?: boolean;
    /** A third, mixed state: a dash instead of the tick, regardless of `checked`. A press clears it, as the platform
     * does (the box is then checked or not, as the input says); bind it to follow. */
    indeterminate?: boolean;
    /** The label, after the box. */
    children?: Snippet;
    /** The native input. */
    ref?: HTMLInputElement | null;
  }

  let {
    checked = $bindable(false),
    indeterminate = $bindable(false),
    children,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();
</script>

<label class={['t-checkbox', 't-pressable', className]} data-press="none">
  <span class="t-checkbox-box t-focus-within">
    <input bind:this={ref} bind:checked bind:indeterminate {...rest} class="t-checkbox-input" type="checkbox" />
    <span class="t-checkbox-frame">
      {#if indeterminate}
        <Glyph name="minus" />
      {:else if checked}
        <Glyph name="check" />
      {/if}
    </span>
  </span>
  {#if children}<span class="t-checkbox-text">{@render children()}</span>{/if}
</label>
