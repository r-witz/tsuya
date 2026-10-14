// Labels (DESIGN.md Labels): the system strings the app gives once to <TsuyaProvider>, read by the components.
import { getContext, setContext } from 'svelte';

// a self-reference: the app's bundler picks dev.js under the "development" condition
import { DEV } from '@tsuya/svelte/env';

import type { TsuyaLabels } from '@tsuya/core';

const KEY = Symbol('tsuya.labels');
const COUNTED = new Set(['results']);

/** Gives the labels to the components inside; TsuyaProvider calls it. A getter, so that a change is followed. */
export function setLabels(labels: () => TsuyaLabels): void {
  setContext(KEY, labels);
}

/**
 * The labels, for a component to read when it renders. Without a provider, reading one throws in development, naming
 * the component and the label, and gives the label's key in production.
 */
export function getLabels(component: string): TsuyaLabels {
  const labels = getContext<(() => TsuyaLabels) | undefined>(KEY);
  return new Proxy({} as TsuyaLabels, {
    get(_, key) {
      if (typeof key !== 'string') return undefined;
      const value = labels?.()[key as keyof TsuyaLabels];
      if (value !== undefined) return value;
      if (DEV) {
        throw new Error(
          `tsuya: <${component}> needs the "${key}" label. Wrap the app in <TsuyaProvider labels={labelsEn}> ` +
            '(labelsEn or labelsFr from @tsuya/core, or your own labels).',
        );
      }
      // a counted label is a function
      return COUNTED.has(key) ? () => key : key;
    },
  });
}
