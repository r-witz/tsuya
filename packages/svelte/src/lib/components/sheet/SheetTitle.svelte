<!--
  @component
  The sheet's title (DESIGN.md, Sheet): title-m; Sheet.Content names the sheet by it.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { getSheet } from './state.svelte.ts';

  interface Props extends Omit<HTMLAttributes<HTMLHeadingElement>, 'children'> {
    /** The title; names the sheet. */
    children: Snippet;
  }

  let { children, class: className, ...rest }: Props = $props();

  const sheet = getSheet('Title');

  $effect(() => sheet.title.register());
</script>

<h2 {...rest} id={sheet.title.id} class={['t-sheet-title', className]}>{@render children()}</h2>
