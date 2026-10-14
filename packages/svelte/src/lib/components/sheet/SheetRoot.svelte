<!--
  @component
  A sheet (DESIGN.md, Sheet): content that rises from the bottom, or a panel from the end edge for desktop. Holds
  Sheet.Content. Always dismissible (Escape, the scrim, a drag down on touch): unlike a dialog, a sheet is never the
  only way to confirm a required decision.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  import { setSheet, SheetState } from './state.svelte.ts';

  interface Props {
    /** Whether it is open. */
    open?: boolean;
    /** From the bottom, or a 400 wide panel from the end edge. Default 'bottom'. */
    side?: 'bottom' | 'end';
    /** Its content. */
    children: Snippet;
  }

  let { open = $bindable(false), side = 'bottom', children }: Props = $props();

  const id = $props.id();
  setSheet(
    new SheetState({
      id,
      open: () => open,
      setOpen: (next) => (open = next),
      side: () => side,
    }),
  );
</script>

{@render children()}
