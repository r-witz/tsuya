<!--
  @component
  The root of a popover (DESIGN.md, Popover): holds whether it is open, for its trigger and content.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  import { PopoverState, setPopover } from './state.svelte.ts';

  interface Props {
    /** Whether it is open. */
    open?: boolean;
    /** Its trigger and content. */
    children: Snippet;
  }

  let { open = $bindable(false), children }: Props = $props();

  const id = $props.id();

  setPopover(
    new PopoverState({
      id,
      open: () => open,
      setOpen: (next) => {
        open = next;
      },
    }),
  );
</script>

{@render children()}
