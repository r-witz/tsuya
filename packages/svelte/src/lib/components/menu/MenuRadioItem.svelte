<!--
  @component
  One of the options of a Menu.RadioGroup (DESIGN.md, Menu): ticked when it is the group's value; choosing it makes
  it so.
-->
<script lang="ts">
  import MenuRow from './MenuRow.svelte';
  import { getRadio, type MenuItemProps } from './state.svelte.ts';

  interface Props extends MenuItemProps {
    /** Identifies it in the group. */
    value: string;
  }

  let { value, ref = $bindable(null), children, ...rest }: Props = $props();

  const group = getRadio();
</script>

<MenuRow
  bind:ref
  {...rest}
  role="menuitemradio"
  checked={group.value === value}
  onchoose={() => {
    group.select(value);
  }}
>
  {@render children()}
</MenuRow>
