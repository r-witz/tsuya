<!--
  @component
  The root of a menu (DESIGN.md, Menu): holds whether it is open, for its trigger and content.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  import { MenuState, setMenu } from './state.svelte.ts';

  interface Props {
    /** Whether it is open. */
    open?: boolean;
    /** Its trigger and content. */
    children: Snippet;
  }

  let { open = $bindable(false), children }: Props = $props();

  const id = $props.id();

  setMenu(
    new MenuState({
      id,
      open: () => open,
      setOpen: (next) => {
        open = next;
      },
    }),
  );
</script>

{@render children()}
