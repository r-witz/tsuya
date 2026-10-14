<!--
  @component
  A row of a menu (DESIGN.md, Menu): an icon in --t-text-muted, the label, a shortcut in mono, and a tick at the end
  when checked. Destructive, it is in --t-danger. A choice closes the menu and focus goes back to the opener.
-->
<script lang="ts">
  import { untrack } from 'svelte';

  import Glyph from '../../internal/Glyph.svelte';
  import { getMenu, type MenuItemProps } from './state.svelte.ts';

  interface Props extends MenuItemProps {
    role: 'menuitem' | 'menuitemcheckbox' | 'menuitemradio';
    checked?: boolean;
    destructive?: boolean;
    onchoose: () => void;
  }

  let {
    role,
    checked,
    disabled = false,
    destructive = false,
    icon,
    shortcut,
    onchoose,
    ref = $bindable(null),
    class: className,
    children,
    ...rest
  }: Props = $props();

  const menu = getMenu('Item');

  // counted, not read: the count changing must not run this again
  $effect(() => {
    if (!destructive) return;
    untrack(() => (menu.destructive += 1));
    return () => {
      untrack(() => (menu.destructive -= 1));
    };
  });
</script>

<button
  bind:this={ref}
  {...rest}
  type="button"
  {role}
  tabindex={-1}
  aria-checked={role === 'menuitem' ? undefined : Boolean(checked)}
  aria-disabled={disabled || undefined}
  class={['t-menu-item', 't-pressable', destructive && 't-menu-item-destructive', className]}
  data-press="highlight"
  onclick={() => {
    if (disabled) return;
    // the menu closes and focus is back on the opener before the choice runs, which may move it on
    menu.close();
    onchoose();
  }}
>
  {#if icon}<span class="t-menu-item-icon">{@render icon()}</span>{/if}
  <span class="t-menu-item-label">{@render children()}</span>
  {#if shortcut}<kbd class="t-menu-item-shortcut" aria-hidden="true">{shortcut}</kbd>{/if}
  {#if checked}<Glyph name="check" />{/if}
</button>
