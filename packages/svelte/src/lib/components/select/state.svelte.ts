// The state a select shares with its parts (DESIGN.md, Select): whether it is open, its trigger, its items in
// document order, and the listbox that holds the active option and chooses one.
import { getContext, setContext } from 'svelte';

import { Listbox, type ListboxOption } from '../../primitives/listbox.svelte.ts';

/** An item as it registers: its option, and its element once it has one. */
export class SelectEntry {
  node = $state<HTMLElement | null>(null);
  readonly option: ListboxOption<unknown>;

  constructor(option: ListboxOption<unknown>) {
    this.option = option;
  }
}

export interface SelectProps {
  id: string;
  value: () => unknown;
  /** Takes the value of the chosen option, of the root's type. */
  onchange: (value: never) => void;
  open: () => boolean;
  setOpen: (open: boolean) => void;
  disabled: () => boolean;
  /** A form needs a value: the trigger says so, and a form does not submit without one. */
  required: () => boolean;
  /** The name of the listbox. */
  label: () => string | undefined;
  /** Below the tablet width, the options open in a sheet. */
  sheetOnPhone: () => boolean;
  /** Labels known before the items render: the server and the trigger use them. */
  items: () => readonly { value: unknown; label: string }[] | undefined;
}

const KEY = Symbol('tsuya.select');

export class SelectState {
  trigger = $state<HTMLElement | null>(null);
  entries: SelectEntry[] = $state.raw([]);

  /** The options in document order once their elements exist, in the order they came before. */
  readonly options: ListboxOption<unknown>[] = $derived.by(() => {
    const entries = [...this.entries];
    if (entries.every((entry) => entry.node)) {
      entries.sort((a, b) =>
        a.node && b.node && a.node.compareDocumentPosition(b.node) & Node.DOCUMENT_POSITION_FOLLOWING ? -1 : 1,
      );
    }
    return entries.map((entry) => entry.option);
  });

  readonly listbox: Listbox<unknown>;
  readonly props: SelectProps;

  constructor(props: SelectProps) {
    this.props = props;
    const value = () => {
      const current = props.value();
      return current === undefined ? [] : [current];
    };
    this.listbox = new Listbox<unknown>({
      id: props.id,
      options: () => this.options,
      value,
      onchange: ([chosen]) => {
        props.onchange(chosen as never);
        this.close();
      },
    });
  }

  get open(): boolean {
    return this.props.open();
  }

  set open(open: boolean) {
    this.props.setOpen(open);
  }

  /** The id of the listbox. */
  get listId(): string {
    return `${this.props.id}-listbox`;
  }

  /** The label of the selected value, from the items or the labels known before them. */
  get selectedLabel(): string | undefined {
    const value = this.props.value();
    if (value === undefined) return undefined;
    return (
      this.options.find((option) => option.value === value)?.label ??
      this.props.items()?.find((item) => item.value === value)?.label
    );
  }

  /** Opens with the selected option active, or the first, or the last when `from` says so. */
  show(from: 'selected' | 'first' | 'last' = 'selected'): void {
    if (this.props.disabled()) return;
    this.open = true;
    const selected = this.options.findIndex((option) => option.value === this.props.value());
    if (from === 'selected' && selected !== -1) this.listbox.move(selected);
    else this.listbox.move(from === 'last' ? 'last' : 'first');
  }

  close(): void {
    this.open = false;
  }

  // the items as they are, which `entries` copies: the items of a branch register while it renders, before the
  // branch it replaces is torn down, and that teardown can read `entries` as it was before them
  readonly #registered: SelectEntry[] = [];

  register(entry: SelectEntry): () => void {
    this.#registered.push(entry);
    this.entries = [...this.#registered];
    return () => {
      this.#registered.splice(this.#registered.indexOf(entry), 1);
      this.entries = [...this.#registered];
    };
  }
}

export const setSelect = (state: SelectState): SelectState => setContext(KEY, state);

export function getSelect(part: string): SelectState {
  const state = getContext<SelectState | undefined>(KEY);
  if (!state) throw new Error(`tsuya: <Select.${part}> goes inside <Select.Root>.`);
  return state;
}

const GROUP = Symbol('tsuya.select.group');

/** The label of the group an item is in. */
export const setGroup = (label: () => string): (() => string) => setContext(GROUP, label);
export const getGroup = (): (() => string) | undefined => getContext(GROUP);
