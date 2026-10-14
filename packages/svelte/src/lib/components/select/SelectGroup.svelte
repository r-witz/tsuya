<!--
  @component
  A group of options in a select (DESIGN.md, Select), under its label.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { setGroup } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The group's heading. */
    label: string;
    /** Its items. */
    children: Snippet;
  }

  let { label, children, class: className, ...rest }: Props = $props();

  const id = $props.id();
  setGroup(() => label);
</script>

<div {...rest} role="group" aria-labelledby={id} class={['t-select-group', className]}>
  <div class="t-label t-select-group-heading" {id}>{label}</div>
  {@render children()}
</div>
