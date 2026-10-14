// Listbox (WAI-ARIA): the state of a list of options while focus stays elsewhere (a select's trigger, a
// combobox's field, the command palette's search): the active option for aria-activedescendant, single or multiple
// selection, type-ahead, groups and the empty state. Select, Combobox and CommandPalette render their options from it.
import { typeahead, typed } from '@tsuya/core/primitives';

export interface ListboxOption<T> {
  value: T;
  label: string;
  disabled?: boolean;
  /** The label of its group; the options of a group are next to each other. */
  group?: string;
}

export interface ListboxProps<T> {
  /** What the ids of the options start with: the component's `$props.id()`. */
  id: string;
  options: () => readonly ListboxOption<T>[];
  /** The selected values: at most one, unless `multiple`. */
  value: () => readonly T[];
  /** Called with the selected values when an option is chosen. */
  onchange: (value: T[]) => void;
  multiple?: boolean;
  /**
   * Whether focus is in a text field, as in a combobox: Home, End, Space and letters are the field's then. Otherwise
   * letters find an option by its label.
   */
  field?: boolean;
}

/** A group of options in order, each with its index in the list. */
export interface ListboxGroup<T> {
  label: string | undefined;
  options: { option: ListboxOption<T>; index: number }[];
}

export class Listbox<T> {
  /** The index of the active option, or -1. */
  active = $state(-1);

  /** The options in their groups. */
  readonly groups: ListboxGroup<T>[] = $derived.by(() => {
    const groups: ListboxGroup<T>[] = [];
    this.options.forEach((option, index) => {
      const last = groups.at(-1);
      if (last && last.label === option.group) last.options.push({ option, index });
      else groups.push({ label: option.group, options: [{ option, index }] });
    });
    return groups;
  });

  readonly #props: ListboxProps<T>;
  readonly #find = typeahead();

  constructor(props: ListboxProps<T>) {
    this.#props = props;
  }

  get options(): readonly ListboxOption<T>[] {
    return this.#props.options();
  }

  /** Whether there is no option to show: the component shows its empty state. */
  get empty(): boolean {
    return this.options.length === 0;
  }

  /** The id of the option at `index`. */
  idOf(index: number): string {
    return `${this.#props.id}-option-${String(index)}`;
  }

  /** The id of the active option, for `aria-activedescendant`. */
  get activeId(): string | undefined {
    return this.active >= 0 && this.active < this.options.length ? this.idOf(this.active) : undefined;
  }

  isSelected(value: T): boolean {
    return this.#props.value().includes(value);
  }

  /** Makes the first, last, next or previous option that is not disabled active, or the one at an index. */
  move(to: 'first' | 'last' | 'next' | 'previous' | number): void {
    const enabled = this.options.flatMap((option, index) => (option.disabled ? [] : [index]));
    if (typeof to === 'number') {
      if (enabled.includes(to)) this.active = to;
      return;
    }
    // an index past the end, left by options that changed, is no active option
    const active = this.active < this.options.length ? this.active : -1;
    const after = enabled.find((index) => index > active);
    const before = enabled.filter((index) => index < active).at(-1);
    const next = {
      first: enabled[0],
      last: enabled.at(-1),
      // from no active option, down goes to the first and up to the last
      next: active < 0 ? enabled[0] : after,
      previous: active < 0 ? enabled.at(-1) : before,
    }[to];
    if (next !== undefined) this.active = next;
  }

  /** Chooses the option at `index` (the active one by default); in a multiple listbox, toggles it. */
  select(index = this.active): void {
    const option = this.options[index];
    if (!option || option.disabled) return;
    const value = this.#props.value();
    if (!this.#props.multiple) this.#props.onchange([option.value]);
    else if (value.includes(option.value)) this.#props.onchange(value.filter((v) => v !== option.value));
    else this.#props.onchange([...value, option.value]);
  }

  /** Handles a key of the element that has focus; true when it was the listbox's, and its default is prevented. */
  keydown(event: KeyboardEvent): boolean {
    // an Enter or arrow that drives an IME composition belongs to the IME, not to the list
    if (event.defaultPrevented || event.isComposing || event.ctrlKey || event.metaKey || event.altKey) return false;
    const field = this.#props.field ?? false;
    if (!field && typed(event)) {
      const index = this.#find(
        event.key,
        this.options.map((option) => (option.disabled ? '' : option.label)),
        this.active,
      );
      if (index !== -1) this.active = index;
    } else if (event.key === 'ArrowDown') this.move('next');
    else if (event.key === 'ArrowUp') this.move('previous');
    else if (event.key === 'Home' && !field) this.move('first');
    else if (event.key === 'End' && !field) this.move('last');
    else if (event.key === 'Enter' || (event.key === ' ' && !field)) {
      if (this.activeId === undefined) return false;
      this.select();
    } else return false;
    event.preventDefault();
    return true;
  }
}
