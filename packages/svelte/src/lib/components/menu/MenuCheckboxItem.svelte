<!--
  @component
  An option of a menu that is on or off (DESIGN.md, Menu): ticked at the end when checked; choosing it toggles it.
-->
<script lang="ts">
  import MenuRow from './MenuRow.svelte';
  import type { MenuItemProps } from './state.svelte.ts';

  interface Props extends MenuItemProps {
    /** Whether it is checked. */
    checked?: boolean;
  }

  let { checked = $bindable(false), ref = $bindable(null), children, ...rest }: Props = $props();
</script>

<MenuRow
  bind:ref
  {...rest}
  role="menuitemcheckbox"
  {checked}
  onchoose={() => {
    checked = !checked;
  }}
>
  {@render children()}
</MenuRow>
