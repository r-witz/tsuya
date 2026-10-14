<!--
  @component
  A radio group (DESIGN.md, RadioGroup): a fieldset of native radios sharing `name`, named by its legend, one tab
  stop with arrow keys moving and selecting as native radios do. Wrap <Radio value> children in it; it reads and
  sets their selection through context, bound to `value`.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLFieldsetAttributes } from 'svelte/elements';

  import { radioArrows } from '../../internal/radio-arrows.ts';
  import { setRadioGroup } from './radio-group-context.ts';

  interface Props extends Omit<HTMLFieldsetAttributes, 'children'> {
    /** The chosen radio's value. */
    value?: string;
    /** The native radios' shared name. */
    name: string;
    /** The group's legend. */
    label: string;
    /** Its radios. */
    children: Snippet;
    /** The fieldset. */
    ref?: HTMLFieldSetElement | null;
  }

  let {
    value = $bindable(),
    name,
    label,
    children,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  setRadioGroup({
    get name() {
      return name;
    },
    get value() {
      return value;
    },
    select: (item) => {
      value = item;
    },
  });
</script>

<fieldset bind:this={ref} {...rest} role="radiogroup" class={['t-radio-group', className]} {@attach radioArrows}>
  <legend class="t-radio-group-legend">{label}</legend>
  {@render children()}
</fieldset>
