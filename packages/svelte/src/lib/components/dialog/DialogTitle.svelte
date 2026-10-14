<!--
  @component
  The dialog's title (DESIGN.md, Dialog): title-m; Dialog.Content names the dialog by it.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { getDialog } from './state.svelte.ts';

  interface Props extends Omit<HTMLAttributes<HTMLHeadingElement>, 'children'> {
    /** The title; names the dialog. */
    children: Snippet;
  }

  let { children, class: className, ...rest }: Props = $props();

  const dialog = getDialog('Title');

  $effect(() => dialog.title.register());
</script>

<h2 {...rest} id={dialog.title.id} class={['t-dialog-title', className]}>{@render children()}</h2>
