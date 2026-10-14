// Type-ahead (WAI-ARIA): the letters typed in a short while find the next item whose label starts with them; the same
// letter again moves through the items that start with it. Used by roving focus and listboxes.

/** How long typed letters add up, in milliseconds; the same in Flutter. */
export const TYPEAHEAD_TIMEOUT = 500;

/**
 * A type-ahead search. Give it each printable key with the labels of the items and the index of the current one; it
 * gives the index to move to, or -1.
 */
export function typeahead(
  timeout = TYPEAHEAD_TIMEOUT,
): (key: string, labels: readonly string[], current: number) => number {
  let query = '';
  let timer: ReturnType<typeof setTimeout> | undefined;
  return (key, labels, current) => {
    clearTimeout(timer);
    timer = setTimeout(() => (query = ''), timeout);
    query += key.toLocaleLowerCase();
    const repeated = query.replaceAll(query.charAt(0), '') === '';
    const search = repeated ? query.slice(0, 1) : query;
    // one letter looks after the current item; more letters may stay on it
    const start = repeated ? current + 1 : Math.max(current, 0);
    for (let i = 0; i < labels.length; i++) {
      const index = (((start + i) % labels.length) + labels.length) % labels.length;
      if (labels[index]?.trim().toLocaleLowerCase().startsWith(search)) return index;
    }
    return -1;
  };
}

/** Whether a key adds to a type-ahead search: one printable character, no modifier, not Space. */
export const typed = (event: KeyboardEvent): boolean =>
  event.key.length === 1 && event.key !== ' ' && !event.ctrlKey && !event.metaKey && !event.altKey;
