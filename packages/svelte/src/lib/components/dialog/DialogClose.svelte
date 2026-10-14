<!--
  @component
  Closes the dialog (DESIGN.md, Dialog): a snippet, so any element can carry the action. By default, when nothing in
  the dialog has `autofocus`, Dialog.Content gives this the initial focus (the least destructive action).
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  import { getDialog } from './state.svelte.ts';

  interface Props {
    /** The action, with the props to spread on its element. */
    children: Snippet<[Record<string | symbol, unknown>]>;
  }

  let { children }: Props = $props();

  const dialog = getDialog('Close');
</script>

{@render children({
  onclick: () => {
    dialog.close();
  },
  'data-tsuya-dialog-close': '',
})}
