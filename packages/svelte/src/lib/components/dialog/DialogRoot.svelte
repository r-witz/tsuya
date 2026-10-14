<!--
  @component
  A dialog (DESIGN.md, Dialog): a decision that needs an answer, or a short focused task. Holds Dialog.Trigger and
  Dialog.Content. `dismissible={false}` makes the decision required: Escape and a press on the scrim no longer close
  it (an explicit Dialog.Close still does). `alert` gives it role="alertdialog", for a dialog that interrupts.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  import { DialogState, setDialog } from './state.svelte.ts';

  interface Props {
    /** Whether it is open. */
    open?: boolean;
    /** Escape and a press on the scrim close it. Default true. */
    dismissible?: boolean;
    /** role="alertdialog", for a dialog that interrupts. Default false. */
    alert?: boolean;
    /** Its trigger and content. */
    children: Snippet;
  }

  let { open = $bindable(false), dismissible = true, alert = false, children }: Props = $props();

  const id = $props.id();
  setDialog(
    new DialogState({
      id,
      open: () => open,
      setOpen: (next) => (open = next),
      dismissible: () => dismissible,
      alert: () => alert,
    }),
  );
</script>

{@render children()}
