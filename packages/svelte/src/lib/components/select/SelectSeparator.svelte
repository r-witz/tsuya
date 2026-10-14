<!--
  @component
  A line between options or groups of a select (DESIGN.md, Select); only drawn, hidden from assistive technology.
-->
<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  let { class: className, ...rest }: HTMLAttributes<HTMLDivElement> = $props();
</script>

<div {...rest} aria-hidden="true" class={['t-select-separator', className]}></div>
