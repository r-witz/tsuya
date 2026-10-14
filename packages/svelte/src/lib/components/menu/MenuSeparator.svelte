<!--
  @component
  A hairline between groups of items of a menu (DESIGN.md, Menu), as before a destructive item.
-->
<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  let { class: className, ...rest }: HTMLAttributes<HTMLDivElement> = $props();
</script>

<div {...rest} role="separator" class={['t-menu-separator', className]}></div>
