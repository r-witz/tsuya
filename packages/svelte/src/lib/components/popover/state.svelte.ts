// The state a popover shares with its parts (DESIGN.md, Popover): whether it is open, its opener, and whether the
// keyboard opened it, which moves focus in.
import { getContext, setContext } from 'svelte';

export interface PopoverProps {
  id: string;
  open: () => boolean;
  setOpen: (open: boolean) => void;
}

const KEY = Symbol('tsuya.popover');

export class PopoverState {
  trigger = $state<HTMLElement | null>(null);
  /** Whether the keyboard opened it: focus then moves in. */
  byKeyboard = $state(false);
  readonly props: PopoverProps;

  constructor(props: PopoverProps) {
    this.props = props;
  }

  get open(): boolean {
    return this.props.open();
  }

  get triggerId(): string {
    return `${this.props.id}-trigger`;
  }

  get contentId(): string {
    return `${this.props.id}-popover`;
  }

  show(byKeyboard: boolean): void {
    this.byKeyboard = byKeyboard;
    this.props.setOpen(true);
  }

  /** Closes it; focus goes back to the opener unless it went somewhere else. */
  close(refocus = true): void {
    this.props.setOpen(false);
    if (refocus) this.trigger?.focus();
  }
}

export const setPopover = (state: PopoverState): PopoverState => setContext(KEY, state);

export function getPopover(part: string): PopoverState {
  const state = getContext<PopoverState | undefined>(KEY);
  if (!state) throw new Error(`tsuya: <Popover.${part}> goes inside <Popover.Root>.`);
  return state;
}
