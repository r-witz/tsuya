// The state an accordion shares with its parts (DESIGN.md, Accordion): which items are open, one or several, the ids
// that tie each header to its content, and the item each part belongs to.
import { getContext, setContext } from 'svelte';

export interface AccordionProps {
  id: string;
  type: () => 'single' | 'multiple';
  value: () => readonly string[];
  setValue: (value: string[]) => void;
}

/** An item, as its header and content read it. */
export interface AccordionItemState {
  value: () => string;
  disabled: () => boolean;
}

const KEY = Symbol('tsuya.accordion');
const ITEM = Symbol('tsuya.accordion.item');

export class AccordionState {
  readonly props: AccordionProps;

  constructor(props: AccordionProps) {
    this.props = props;
  }

  isOpen(item: string): boolean {
    return this.props.value().includes(item);
  }

  /** Opens or closes an item; opening one closes the others when only one may be open. */
  toggle(item: string): void {
    const open = this.props.value();
    if (open.includes(item)) this.props.setValue(open.filter((each) => each !== item));
    else this.props.setValue(this.props.type() === 'single' ? [item] : [...open, item]);
  }

  triggerId(item: string): string {
    return `${this.props.id}-trigger-${encodeURIComponent(item)}`;
  }

  contentId(item: string): string {
    return `${this.props.id}-content-${encodeURIComponent(item)}`;
  }
}

export const setAccordion = (state: AccordionState): AccordionState => setContext(KEY, state);

export function getAccordion(part: string): AccordionState {
  const state = getContext<AccordionState | undefined>(KEY);
  if (!state) throw new Error(`tsuya: <Accordion.${part}> goes inside <Accordion.Root>.`);
  return state;
}

export const setItem = (item: AccordionItemState): AccordionItemState => setContext(ITEM, item);

export function getItem(part: string): AccordionItemState {
  const item = getContext<AccordionItemState | undefined>(ITEM);
  if (!item) throw new Error(`tsuya: <Accordion.${part}> goes inside <Accordion.Item>.`);
  return item;
}
