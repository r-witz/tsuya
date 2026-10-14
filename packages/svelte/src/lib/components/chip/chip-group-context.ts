// The context a ChipGroup gives its Chip children (DESIGN.md, Chip): whether selection is single or multiple, and
// how a chip reads and toggles its own selection by its value.
import { getContext, setContext } from 'svelte';

const KEY = Symbol('tsuya.chip-group');

export interface ChipGroupContext {
  readonly multiple: boolean;
  isSelected: (value: string | undefined) => boolean;
  toggle: (value: string | undefined) => void;
}

export function setChipGroup(context: ChipGroupContext): void {
  setContext(KEY, context);
}

/** The group a Chip renders in, if any: it then takes the group's radio or toggle-button semantics. */
export function getChipGroup(): ChipGroupContext | undefined {
  return getContext(KEY);
}
