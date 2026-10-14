<!--
  @component
  A radio (DESIGN.md, RadioGroup): a native radio drawn as a 20 circle that fills with the accent and an on-accent
  dot when selected. Used inside a <RadioGroup>, which it reads and changes through context; with its label the row
  is pressable. The focus ring sits on the circle, around the hidden native input.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLInputAttributes } from 'svelte/elements';

  import { getRadioGroup } from './radio-group-context.ts';

  interface Props extends Omit<HTMLInputAttributes, 'type' | 'checked' | 'name' | 'children'> {
    /** Identifies this radio to the group. */
    value: string;
    /** The label, after the circle. */
    children?: Snippet;
    /** The native input. */
    ref?: HTMLInputElement | null;
  }

  let { value, children, ref = $bindable(null), class: className, ...rest }: Props = $props();

  const group = getRadioGroup();
  const checked = $derived(group.value === value);
</script>

<label class={['t-radio', 't-pressable', className]} data-press="none">
  <span class="t-radio-box t-focus-within">
    <input
      bind:this={ref}
      {...rest}
      class="t-radio-input"
      type="radio"
      name={group.name}
      {value}
      {checked}
      onchange={() => {
        group.select(value);
      }}
    />
    <span class="t-radio-frame"></span>
  </span>
  {#if children}<span class="t-radio-text">{@render children()}</span>{/if}
</label>
