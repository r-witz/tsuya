<!--
  @component
  Options of a menu of which one is chosen (DESIGN.md, Menu): a group named by `label`, bound to `value`.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { setRadio } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The chosen item's value. */
    value?: string;
    /** The name of the group. */
    label: string;
    /** Its radio items. */
    children: Snippet;
  }

  let { value = $bindable(), label, children, ...rest }: Props = $props();

  setRadio({
    get value() {
      return value;
    },
    select: (next) => {
      value = next;
    },
  });
</script>

<div {...rest} role="group" aria-label={label}>
  {@render children()}
</div>
