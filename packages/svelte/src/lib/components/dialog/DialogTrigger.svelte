<!--
  @component
  Opens the dialog (DESIGN.md, Dialog): a snippet, like Tooltip's trigger, so any element can open it (a Button of any
  variant, a menu item, a row) without nesting a button inside one. Spreads `onclick` on it.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  import { getDialog } from './state.svelte.ts';

  interface Props {
    /** The trigger, with the props to spread on its element. */
    children: Snippet<[Record<string | symbol, unknown>]>;
  }

  let { children }: Props = $props();

  const dialog = getDialog('Trigger');
</script>

{@render children({
  onclick: () => {
    dialog.open = true;
  },
})}
