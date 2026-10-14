<!--
  @component
  An action of a menu (DESIGN.md, Menu): `onselect` runs when it is chosen, after the menu has closed. A destructive
  item comes last, after a separator.
-->
<script lang="ts">
  import MenuRow from './MenuRow.svelte';
  import type { MenuItemProps } from './state.svelte.ts';

  interface Props extends MenuItemProps {
    /** In --t-danger; it comes last, after a separator. */
    destructive?: boolean;
    /** Called when it is chosen; the menu then closes. */
    onselect?: () => void;
  }

  let { onselect, ref = $bindable(null), children, ...rest }: Props = $props();
</script>

<MenuRow
  bind:ref
  {...rest}
  role="menuitem"
  onchoose={() => {
    onselect?.();
  }}
>
  {@render children()}
</MenuRow>
