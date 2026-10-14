// The state tabs share with their parts (DESIGN.md, Tabs): the selected value, the triggers in order, and the ids
// that tie each tab to its panel.
import { getContext, setContext } from 'svelte';

export interface TabsProps {
  id: string;
  value: () => string | undefined;
  setValue: (value: string) => void;
  /** Arrows move focus only; Enter and Space select. */
  manual: () => boolean;
}

const KEY = Symbol('tsuya.tabs');

export class TabsState {
  /** The triggers, in the order they rendered. */
  triggers: { readonly value: string }[] = $state.raw([]);
  readonly props: TabsProps;

  constructor(props: TabsProps) {
    this.props = props;
  }

  /** The selected value: the first tab's while none is chosen. */
  get value(): string | undefined {
    return this.props.value() ?? this.triggers[0]?.value;
  }

  select(value: string): void {
    this.props.setValue(value);
  }

  tabId(value: string): string {
    return `${this.props.id}-tab-${encodeURIComponent(value)}`;
  }

  panelId(value: string): string {
    return `${this.props.id}-panel-${encodeURIComponent(value)}`;
  }

  register(trigger: { readonly value: string }): () => void {
    this.triggers = [...this.triggers, trigger];
    return () => {
      this.triggers = this.triggers.filter((each) => each !== trigger);
    };
  }
}

export const setTabs = (state: TabsState): TabsState => setContext(KEY, state);

export function getTabs(part: string): TabsState {
  const state = getContext<TabsState | undefined>(KEY);
  if (!state) throw new Error(`tsuya: <Tabs.${part}> goes inside <Tabs.Root>.`);
  return state;
}
