<!--
  @component
  A heading over a few items of a menu (DESIGN.md, Menu), in --t-type-caption and --t-text-muted. It is not an item:
  focus passes it.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  let { children }: { children: Snippet } = $props();
</script>

<div role="presentation" class="t-menu-label">{@render children()}</div>
