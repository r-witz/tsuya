<!--
  @component
  A row of chips that scrolls sideways (DESIGN.md, Chip): single selection (radio semantics) or `multiple` (toggle
  buttons), one tab stop with roving focus. Wrap <Chip value> children in it; it reads and drives their selection
  through context, bound to `value` (a value, or an array of them when `multiple`).
-->
<script lang="ts">
  import { rovingFocus } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { setChipGroup } from './chip-group-context.ts';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** The selected value, or the selected values with `multiple`. */
    value?: string | string[];
    /** Several chips can be selected. */
    multiple?: boolean;
    /** The accessible name of the group. */
    label: string;
    /** Its chips. */
    children: Snippet;
    /** The group's element. */
    ref?: HTMLDivElement | null;
  }

  let {
    value = $bindable(),
    multiple = false,
    label,
    children,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  setChipGroup({
    get multiple() {
      return multiple;
    },
    isSelected: (item) => (multiple ? Array.isArray(value) && value.includes(item ?? '') : value === item),
    toggle: (item) => {
      if (item === undefined) return;
      if (multiple) {
        const list = Array.isArray(value) ? value : [];
        value = list.includes(item) ? list.filter((each) => each !== item) : [...list, item];
      } else {
        value = item;
      }
    },
  });
</script>

<div
  bind:this={ref}
  {...rest}
  role={multiple ? 'group' : 'radiogroup'}
  aria-label={label}
  class={['t-chip-group', className]}
  {@attach rovingFocus({ items: '.t-chip', orientation: 'horizontal' })}
>
  {@render children()}
</div>
