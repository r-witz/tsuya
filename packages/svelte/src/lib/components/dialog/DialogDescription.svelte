<!--
  @component
  The dialog's body text (DESIGN.md, Dialog): body, text-muted; Dialog.Content reads it as the dialog's description.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { getDialog } from './state.svelte.ts';

  interface Props extends Omit<HTMLAttributes<HTMLParagraphElement>, 'children'> {
    /** The text. */
    children: Snippet;
  }

  let { children, class: className, ...rest }: Props = $props();

  const dialog = getDialog('Description');

  $effect(() => dialog.description.register());
</script>

<p {...rest} id={dialog.description.id} class={['t-dialog-description', className]}>{@render children()}</p>
