// Role, name and state (G5): axe-core finds no violation in the scenarios (scenarios.ts), closed and open, in both
// modes.
import axe from 'axe-core';
import { afterEach, describe, expect, test } from 'vitest';
import { commands, page } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { SCENARIOS } from './scenarios.ts';

// the violations, by rule and element, once the transitions have ended: a panel fading in has a lower contrast
async function audit(container: Element): Promise<string[]> {
  const ending = document
    .getAnimations()
    .filter((animation) => animation.effect?.getComputedTiming().endTime !== Infinity);
  await Promise.allSettled(ending.map((animation) => animation.finished));
  const { violations } = await axe.run(container, { resultTypes: ['violations'] });
  return violations.flatMap((violation) =>
    violation.nodes.map((node) => `${violation.id}: ${node.target.join(' ')} ${node.failureSummary ?? ''}`),
  );
}

afterEach(async () => {
  await commands.emulateMedia({ colorScheme: null });
});

describe.each(['light', 'dark'] as const)('%s mode', (mode) => {
  test.each(SCENARIOS.filter((scenario) => !scenario.skip?.a11y))(
    '$name',
    async ({ fixture, props, viewport = [800, 600], open }) => {
      await commands.emulateMedia({ colorScheme: mode });
      await page.viewport(...viewport);
      const screen = await render(fixture, props);
      expect(await audit(screen.container)).toEqual([]);
      if (!open) return;
      const opened = await open(screen);
      expect(await audit(screen.container)).toEqual([]);
      // portalled out of the container, as a toast is: audited where it is
      if (!screen.container.contains(opened)) expect(await audit(opened)).toEqual([]);
    },
  );
});
