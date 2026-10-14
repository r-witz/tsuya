// The row a control sits in (DESIGN.md, List): a ListItem gives the ids of its title and subtitle, so that a
// label-less Switch in its trailing slot is named by the row, as Flutter's ListItem merges it.
import { getContext, setContext } from 'svelte';

const KEY = Symbol('tsuya.row');

export interface RowNames {
  /** The id of the row's title. */
  title: string;
  /** The id of the row's subtitle, when it has one. */
  subtitle?: string;
}

/** Gives the names of the row to the controls inside; ListItem calls it. A getter, so that a change is followed. */
export function setRow(row: () => RowNames | undefined): void {
  setContext(KEY, row);
}

/** A getter of the names of the row around: undefined outside a plain row. */
export function getRow(): () => RowNames | undefined {
  return getContext<(() => RowNames | undefined) | undefined>(KEY) ?? (() => undefined);
}
