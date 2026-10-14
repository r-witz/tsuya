// Whether a sidebar shows its icons only (DESIGN.md, Sidebar): its items and groups read it.
import { getContext, setContext } from 'svelte';

const KEY = Symbol('tsuya.sidebar');

export const setCollapsed = (collapsed: () => boolean): (() => boolean) => setContext(KEY, collapsed);
export const getCollapsed = (): (() => boolean) => getContext<(() => boolean) | undefined>(KEY) ?? (() => false);
