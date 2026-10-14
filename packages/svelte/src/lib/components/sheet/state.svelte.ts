// The state a sheet shares with its parts (DESIGN.md, Sheet): whether it is open, which edge it rises from, and the
// id that ties its title to it.
import { getContext, setContext } from 'svelte';

import { Part } from '../../internal/part.svelte.ts';

export interface SheetProps {
  id: string;
  open: () => boolean;
  setOpen: (open: boolean) => void;
  side: () => 'bottom' | 'end';
}

const KEY = Symbol('tsuya.sheet');

export class SheetState {
  readonly props: SheetProps;
  /** Sheet.Title, which names it. */
  readonly title: Part;

  constructor(props: SheetProps) {
    this.props = props;
    this.title = new Part(`${props.id}-title`, true);
  }

  get open(): boolean {
    return this.props.open();
  }

  set open(open: boolean) {
    this.props.setOpen(open);
  }

  close(): void {
    this.open = false;
  }
}

export const setSheet = (state: SheetState): SheetState => setContext(KEY, state);

export function getSheet(part: string): SheetState {
  const state = getContext<SheetState | undefined>(KEY);
  if (!state) throw new Error(`tsuya: <Sheet.${part}> goes inside <Sheet.Root>.`);
  return state;
}
