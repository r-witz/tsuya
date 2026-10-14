// The state a dialog shares with its parts (DESIGN.md, Dialog): whether it is open, whether it may be dismissed, and
// whether it interrupts (alertdialog); the ids that tie its title and description to the dialog.
import { getContext, setContext } from 'svelte';

import { Part } from '../../internal/part.svelte.ts';

export interface DialogProps {
  id: string;
  open: () => boolean;
  setOpen: (open: boolean) => void;
  dismissible: () => boolean;
  alert: () => boolean;
}

const KEY = Symbol('tsuya.dialog');

export class DialogState {
  readonly props: DialogProps;
  /** Dialog.Title, which names it. */
  readonly title: Part;
  /** Dialog.Description, which describes it. */
  readonly description: Part;

  constructor(props: DialogProps) {
    this.props = props;
    this.title = new Part(`${props.id}-title`, true);
    this.description = new Part(`${props.id}-description`);
  }

  get open(): boolean {
    return this.props.open();
  }

  set open(open: boolean) {
    this.props.setOpen(open);
  }

  /** Closes it: an explicit choice (Dialog.Close, or a consumer's own action), never blocked by `dismissible`. */
  close(): void {
    this.open = false;
  }

  /** Escape or a press on the scrim asks to close: blocked while the decision is required (`dismissible={false}`). */
  dismiss(): void {
    if (this.props.dismissible()) this.close();
  }
}

export const setDialog = (state: DialogState): DialogState => setContext(KEY, state);

export function getDialog(part: string): DialogState {
  const state = getContext<DialogState | undefined>(KEY);
  if (!state) throw new Error(`tsuya: <Dialog.${part}> goes inside <Dialog.Root>.`);
  return state;
}
