<!--
  @component
  The dialog's actions (DESIGN.md, Dialog): at the end, wrapping when needed. Put the main one last.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** Its buttons. */
    children: Snippet;
  }

  let { children, class: className, ...rest }: Props = $props();
</script>

<div {...rest} class={['t-dialog-actions', className]}>{@render children()}</div>
