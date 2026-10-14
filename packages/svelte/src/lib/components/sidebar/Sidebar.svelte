<!--
  @component
  The navigation of a desktop shell (DESIGN.md, Sidebar): 240 wide, `--t-space-12` around its items and groups; it
  replaces the tab bar from `--t-breakpoint-desktop` wide. `collapsed`, it shows the icons only, 72 wide.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { setCollapsed } from './state.ts';

  interface Props extends HTMLAttributes<HTMLElement> {
    /** The icons only. */
    collapsed?: boolean;
    /** Its groups and items. */
    children: Snippet;
  }

  let { collapsed = false, class: className, children, ...rest }: Props = $props();

  setCollapsed(() => collapsed);
</script>

<nav {...rest} class={['t-sidebar', collapsed && 't-sidebar-collapsed', className]}>
  {@render children()}
</nav>
