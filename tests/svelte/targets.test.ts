// Targets (G3): every interactive element answers on at least 24 × 24 with a mouse, 44 × 44 on touch (the
// chromium-touch instance of vitest.config.ts emulates a phone), and a press 1 px inside its target lands on it, in the
// scenarios (scenarios.ts), closed and open. The elements are found, not listed: whatever takes focus or a press.
import { beforeEach, expect, test } from 'vitest';
import { page } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { SCENARIOS } from './scenarios.ts';

const TOUCH = matchMedia('(pointer: coarse)').matches;
const MINIMUM = TOUCH ? 44 : 24;
// what takes a press or a tap; focusable containers (a tab panel, a dialog) are read, not pressed
const INTERACTIVE = [
  'a[href]',
  'button',
  'input:not([type="hidden"])',
  'select',
  'textarea',
  '[role="option"]',
  '[tabindex]:not([tabindex="-1"], [role="tabpanel"], [role="dialog"], [role="alertdialog"], [role="region"])',
].join(', ');

// the box that answers for an element: its own, or for an input its field's or its label's, grown to the invisible
// ::after that pressables and fields add around a smaller drawing
function target(element: Element): { owner: Element; box: DOMRect } {
  const owner = (element.matches('input') && element.closest('.t-text-input, label')) || element;
  const box = owner.getBoundingClientRect();
  if (!owner.matches('.t-pressable, .t-text-input')) return { owner, box };
  const after = getComputedStyle(owner, '::after');
  if (after.content === 'none') return { owner, box };
  // an input draws no ::after in Firefox: its width is then 'auto'
  const [width, height] = [
    Math.max(box.width, parseFloat(after.width) || 0),
    Math.max(box.height, parseFloat(after.height) || 0),
  ];
  const [x, y] = [box.left + box.width / 2, box.top + box.height / 2];
  return { owner, box: new DOMRect(x - width / 2, y - height / 2, width, height) };
}

// what is wrong with the targets of the visible, enabled interactive elements in `root`
function misses(root: Element): string[] {
  const found: string[] = [];
  for (const element of root.querySelectorAll<HTMLElement>(INTERACTIVE)) {
    if (!element.checkVisibility() || element.matches(':disabled, [aria-disabled="true"]')) continue;
    // what takes no press, such as the native select a select keeps for its form, has no target
    if (getComputedStyle(element).pointerEvents === 'none') continue;
    element.scrollIntoView({ block: 'nearest' });
    const { owner, box } = target(element);
    const name = element.getAttribute('aria-label') ?? (element.textContent.trim() || element.outerHTML.slice(0, 40));
    if (box.width < MINIMUM - 0.5 || box.height < MINIMUM - 0.5) {
      found.push(`${name}: ${String(box.width)} × ${String(box.height)}`);
    }
    const [x, y] = [box.left + box.width / 2, box.top + box.height / 2];
    // 2 px in from each edge: WebKit hit-tests a box at a fractional offset as if snapped to the pixel
    for (const [px, py] of [
      [box.left + 2, y],
      [box.right - 2, y],
      [x, box.top + 2],
      [x, box.bottom - 2],
    ] as const) {
      const hit = document.elementFromPoint(px, py);
      if (!hit || !owner.contains(hit)) {
        found.push(
          `${name}: a press at ${String(px)}, ${String(py)} lands on ${hit?.outerHTML.slice(0, 60) ?? 'nothing'}`,
        );
      }
    }
  }
  return found;
}

beforeEach(async () => {
  await page.viewport(800, 1000);
});

test.each(SCENARIOS.filter((scenario) => !scenario.skip?.targets))(
  '$name',
  async ({ fixture, props, viewport, open }) => {
    if (viewport) await page.viewport(...viewport);
    const screen = await render(fixture, props);
    expect(misses(screen.container)).toEqual([]);
    if (open) expect(misses(await open(screen))).toEqual([]);
  },
);
