// The state a menu shares with its parts (DESIGN.md, Menu): whether it is open, its opener, where focus starts, and
// whether it holds a destructive item, which keeps it off glass.
import { getContext, setContext, type Snippet } from 'svelte';
import type { HTMLButtonAttributes } from 'svelte/elements';

export interface MenuProps {
  id: string;
  open: () => boolean;
  setOpen: (open: boolean) => void;
}

const KEY = Symbol('tsuya.menu');

export class MenuState {
  trigger = $state<HTMLElement | null>(null);
  /** The item that takes focus as it opens. */
  from = $state<'first' | 'last'>('first');
  destructive = $state(0);
  readonly props: MenuProps;

  constructor(props: MenuProps) {
    this.props = props;
  }

  get open(): boolean {
    return this.props.open();
  }

  get triggerId(): string {
    return `${this.props.id}-trigger`;
  }

  get contentId(): string {
    return `${this.props.id}-menu`;
  }

  show(from: 'first' | 'last' = 'first'): void {
    this.from = from;
    this.props.setOpen(true);
  }

  /** Closes it; focus goes back to the opener unless it went somewhere else. */
  close(refocus = true): void {
    this.props.setOpen(false);
    if (refocus) this.trigger?.focus();
  }
}

export const setMenu = (state: MenuState): MenuState => setContext(KEY, state);

export function getMenu(part: string): MenuState {
  const state = getContext<MenuState | undefined>(KEY);
  if (!state) throw new Error(`tsuya: <Menu.${part}> goes inside <Menu.Root>.`);
  return state;
}

const RADIO = Symbol('tsuya.menu.radio');

export interface MenuRadio {
  readonly value: string | undefined;
  select: (value: string) => void;
}

export const setRadio = (group: MenuRadio): MenuRadio => setContext(RADIO, group);

export function getRadio(): MenuRadio {
  const group = getContext<MenuRadio | undefined>(RADIO);
  if (!group) throw new Error('tsuya: <Menu.RadioItem> goes inside <Menu.RadioGroup>.');
  return group;
}

/** What every item of a menu takes. */
export interface MenuItemProps extends Omit<HTMLButtonAttributes, 'children' | 'role' | 'disabled'> {
  /** Cannot be chosen. */
  disabled?: boolean;
  /** An icon before the label. */
  icon?: Snippet;
  /** Shown at the end, as "⌘ R"; seen, not read (give the item `aria-keyshortcuts` to announce it). */
  shortcut?: string;
  /** The item's element. */
  ref?: HTMLButtonElement | null;
  /** The label. */
  children: Snippet;
}
