// Roving focus (WAI-ARIA): one tab stop for a group of items. Arrows move between them in visual order
// (mirrored right to left), Home and End go to the ends, typed letters find an item. Chip groups, menus, tabs and
// the tab bar use it.
import type { Attachment } from './attachment.ts';

import { typeahead as search, typed } from './typeahead.ts';

export interface RovingOptions {
  /** A selector for the items inside the group. */
  items: string;
  /** Which arrows move: left and right, up and down, or both. Default 'both'. */
  orientation?: 'horizontal' | 'vertical' | 'both';
  /** Whether moving past the last item comes back to the first. Default true. */
  wrap?: boolean;
  /** Whether typed letters find an item by its label. Default false. */
  typeahead?: boolean;
  /** Whether disabled items take focus, as menu items do (announced as disabled). Default false. */
  disabledFocusable?: boolean;
  /** Called when a key moves focus to an item: a radio group or tabs select it. */
  onmove?: (item: HTMLElement) => void;
}

const SELECTED = '[aria-selected="true"], [aria-checked="true"], [aria-current]:not([aria-current="false"])';
const SELECTION = ['aria-selected', 'aria-checked', 'aria-current'];

const label = (item: HTMLElement) => item.getAttribute('aria-label') ?? item.textContent;

/**
 * `{@attach rovingFocus({ items: '[role="tab"]' })}` on the group. The tab stop is the item focused last, else the
 * selected one, else the first; when the selection changes while focus is elsewhere, it moves to the new one.
 */
export function rovingFocus(options: RovingOptions): Attachment<HTMLElement> {
  return (group) => {
    const { orientation = 'both', wrap = true, disabledFocusable = false } = options;
    const find = options.typeahead ? search() : undefined;
    const reachable = (item: HTMLElement) => disabledFocusable || !item.matches(':disabled, [aria-disabled="true"]');
    const items = () => [...group.querySelectorAll<HTMLElement>(options.items)];
    let current: HTMLElement | undefined;

    const settle = () => {
      const all = items();
      if (!current || !all.includes(current) || !reachable(current)) {
        current = all.find((item) => item.matches(SELECTED) && reachable(item)) ?? all.find(reachable);
      }
      for (const item of all) item.tabIndex = item === current ? 0 : -1;
    };

    const move = (item: HTMLElement | undefined) => {
      if (!item) return;
      current = item;
      settle();
      item.focus();
      options.onmove?.(item);
    };

    const onkeydown = (event: KeyboardEvent) => {
      if (event.defaultPrevented) return;
      const all = items().filter(reachable);
      const at = all.indexOf(event.target as HTMLElement);
      // keys inside an item, such as a text field in it, are its own
      if (at === -1) return;
      if (find && typed(event)) {
        const index = find(event.key, all.map(label), at);
        if (index !== -1) {
          event.preventDefault();
          move(all[index]);
        }
        return;
      }
      if (event.ctrlKey || event.metaKey || event.altKey || event.shiftKey) return;
      const horizontal = orientation !== 'vertical';
      const vertical = orientation !== 'horizontal';
      const rtl = getComputedStyle(group).direction === 'rtl';
      const steps: Record<string, number | undefined> = {
        ArrowRight: horizontal ? (rtl ? -1 : 1) : undefined,
        ArrowLeft: horizontal ? (rtl ? 1 : -1) : undefined,
        ArrowDown: vertical ? 1 : undefined,
        ArrowUp: vertical ? -1 : undefined,
      };
      let next: HTMLElement | undefined;
      if (event.key === 'Home') next = all[0];
      else if (event.key === 'End') next = all.at(-1);
      else {
        const step = steps[event.key];
        if (step === undefined) return;
        const index = at + step;
        next = wrap ? all[(index + all.length) % all.length] : all[index];
        if (!next) {
          event.preventDefault();
          return;
        }
      }
      event.preventDefault();
      move(next);
    };

    const onfocusin = (event: FocusEvent) => {
      const item = items().find((each) => each === event.target);
      if (item && item !== current && reachable(item)) {
        current = item;
        settle();
      }
    };

    // items come and go and change state: the tab stop follows, and goes to a new selection made from elsewhere
    const observer = new MutationObserver((records) => {
      const selection = records.some((record) => SELECTION.includes(record.attributeName ?? ''));
      if (selection && !group.contains(document.activeElement)) current = undefined;
      settle();
    });
    observer.observe(group, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: [...SELECTION, 'aria-disabled', 'disabled'],
    });
    settle();
    group.addEventListener('keydown', onkeydown);
    group.addEventListener('focusin', onfocusin);
    return () => {
      observer.disconnect();
      group.removeEventListener('keydown', onkeydown);
      group.removeEventListener('focusin', onfocusin);
    };
  };
}
