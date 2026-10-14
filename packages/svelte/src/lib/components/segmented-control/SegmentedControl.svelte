<!--
  @component
  A segmented control (DESIGN.md, SegmentedControl): 2 to 5 options seen together as native radios, one always
  selected (the first while there is no value); `expand` shares the width equally; when
  the segments do not fit, they shrink and their labels wrap. A segment with an icon shows the
  icon alone, named by its label.
-->
<script lang="ts" module>
  import { HIDDEN } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';

  export interface SegmentOption {
    /** Identifies the segment. */
    value: string;
    /** Its text. */
    label: string;
    /** Shown alone instead of the label, which then only names the segment. */
    icon?: Snippet;
  }
</script>

<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  import { radioArrows } from '../../internal/radio-arrows.ts';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** The selected segment's value. */
    value?: string;
    /** The group's accessible name. */
    label: string;
    /** The segments. */
    options: SegmentOption[];
    /** Segments share the width equally. */
    expand?: boolean;
    /** The group's element. */
    ref?: HTMLDivElement | null;
  }

  let {
    value = $bindable(),
    label,
    options,
    expand = false,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  const uid = $props.id();
  const selected = $derived(value ?? options[0]?.value);
</script>

<div
  bind:this={ref}
  {...rest}
  role="radiogroup"
  aria-label={label}
  class={['t-segmented', expand && 't-segmented-expand', className]}
  {@attach radioArrows}
>
  {#each options as option (option.value)}
    <label class="t-segmented-segment t-pressable t-focus-within" data-press="none">
      <input
        class="t-segmented-input"
        type="radio"
        name={uid}
        value={option.value}
        checked={selected === option.value}
        onchange={() => {
          value = option.value;
        }}
      />
      <span class="t-segmented-content">
        {#if option.icon}
          {@render option.icon()}
          <span style={HIDDEN}>{option.label}</span>
        {:else}
          {option.label}
        {/if}
      </span>
    </label>
  {/each}
</div>
