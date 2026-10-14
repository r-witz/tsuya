// Listbox (G6): the active option for aria-activedescendant, single and multiple selection, type-ahead,
// groups and the empty state; in a text field, Home, End, Space and letters stay the field's.
import { expect, test } from 'vitest';

import {
  Listbox,
  type ListboxOption,
  type ListboxProps,
} from '../../packages/svelte/src/lib/primitives/listbox.svelte.ts';
import { TYPEAHEAD_TIMEOUT } from '../../packages/core/src/primitives/typeahead.ts';

const OPTIONS: ListboxOption<string>[] = [
  { value: 'fr', label: 'France', group: 'Europe' },
  { value: 'de', label: 'Germany', group: 'Europe', disabled: true },
  { value: 'gr', label: 'Greece', group: 'Europe' },
  { value: 'jp', label: 'Japan', group: 'Asia' },
  { value: 'gb', label: 'Great Britain' },
];

function make(props: Partial<ListboxProps<string>> = {}) {
  const state = { value: [] as string[] };
  const listbox = new Listbox<string>({
    id: 'country',
    options: () => OPTIONS,
    value: () => state.value,
    onchange: (value) => (state.value = value),
    ...props,
  });
  // a key as the element with focus gets it: handled or not, and whether its default was prevented
  const press = (key: string) => {
    const event = new KeyboardEvent('keydown', { key, cancelable: true });
    return [listbox.keydown(event), event.defaultPrevented];
  };
  return { listbox, state, press };
}

test('the options in their groups, with ids', () => {
  const { listbox } = make();
  expect(listbox.groups.map((g) => [g.label, g.options.map((o) => o.index)])).toEqual([
    ['Europe', [0, 1, 2]],
    ['Asia', [3]],
    [undefined, [4]],
  ]);
  expect(listbox.idOf(3)).toBe('country-option-3');
  expect(listbox.empty).toBe(false);
  expect(make({ options: () => [] }).listbox.empty).toBe(true);
});

test('arrows, Home and End move the active option past disabled ones, without wrapping', () => {
  const { listbox, press } = make();
  expect(listbox.activeId).toBeUndefined();
  expect(press('ArrowDown')).toEqual([true, true]);
  expect(listbox.activeId).toBe('country-option-0');
  press('ArrowDown');
  expect(listbox.active).toBe(2);
  press('End');
  press('ArrowDown');
  expect(listbox.active).toBe(4);
  press('Home');
  press('ArrowUp');
  expect(listbox.active).toBe(0);
  const fresh = make();
  fresh.press('ArrowUp');
  expect(fresh.listbox.active).toBe(4);
  listbox.move(1);
  expect(listbox.active).toBe(0);
  listbox.move(3);
  expect(listbox.active).toBe(3);
});

test('Enter and Space choose the active option; a multiple listbox toggles it; disabled ones are not chosen', () => {
  const single = make();
  expect(single.press('Enter')).toEqual([false, false]);
  single.press('ArrowDown');
  single.press('Enter');
  expect(single.state.value).toEqual(['fr']);
  single.press('ArrowDown');
  single.press(' ');
  expect(single.state.value).toEqual(['gr']);
  expect(single.listbox.isSelected('gr')).toBe(true);
  single.listbox.select(1);
  expect(single.state.value).toEqual(['gr']);

  const multiple = make({ multiple: true });
  multiple.press('ArrowDown');
  multiple.press(' ');
  multiple.press('ArrowDown');
  multiple.press('Enter');
  expect(multiple.state.value).toEqual(['fr', 'gr']);
  multiple.press(' ');
  expect(multiple.state.value).toEqual(['fr']);
});

test('typed letters find an option, the same letter moves on, past disabled options', async () => {
  const { listbox, press } = make();
  expect(press('g')).toEqual([true, true]);
  expect(listbox.active).toBe(2);
  press('g');
  expect(listbox.active).toBe(4);
  await new Promise((resolve) => setTimeout(resolve, TYPEAHEAD_TIMEOUT + 100));
  press('j');
  expect(listbox.active).toBe(3);
});

test('in a text field, Home, End, Space and letters are left to it', () => {
  const { listbox, press, state } = make({ field: true });
  for (const key of ['Home', 'End', ' ', 'g']) expect(press(key), key).toEqual([false, false]);
  expect(listbox.active).toBe(-1);
  press('ArrowDown');
  press('Enter');
  expect(state.value).toEqual(['fr']);
});
