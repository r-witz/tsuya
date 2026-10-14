// The cross-fade of a new pair (DESIGN.md, Accent), as painted: a control that transitions a colour of its own (a
// pressable's background) follows the accent to the new pair and never flashes back towards the old one, whether the
// region is a box or `display: contents`. Firefox, which runs CSS transitions of the registered accent colours apart
// from those of the elements inside, painted such controls going back and forth between the two pairs.
import { expect, test, type Page } from '@playwright/test';

import { hex, open } from './support.ts';

const PAIR = { seed: '#2A9D8F', light: '#03786C', dark: '#2FA193' };
const OTHER = { seed: '#7A3FB0', light: '#7A3FB0', dark: '#B07BEA' };

// the centre pixel of #control, as painted, about every frame over `ms` after `start` runs in the page
async function paint(page: Page, start: () => void, ms: number): Promise<number[][]> {
  const box = await page.locator('#control').boundingBox();
  if (!box) throw new Error('no #control');
  const clip = { x: Math.round(box.x + box.width / 2), y: Math.round(box.y + box.height / 2), width: 1, height: 1 };
  await page.evaluate(start);
  const frames: number[][] = [];
  const end = Date.now() + ms;
  while (Date.now() < end) {
    const png = await page.screenshot({ clip, scale: 'css' });
    frames.push(
      await page.evaluate(async (png) => {
        const bitmap = await createImageBitmap(await (await fetch(`data:image/png;base64,${png}`)).blob());
        const context = new OffscreenCanvas(1, 1).getContext('2d');
        if (!context) throw new Error('no 2D canvas');
        context.drawImage(bitmap, 0, 0);
        return [...context.getImageData(0, 0, 1, 1).data.slice(0, 3)];
      }, png.toString('base64')),
    );
  }
  return frames;
}

const distance = (a: number[], b: number[]) => Math.hypot(...a.map((v, i) => v - (b[i] ?? 0)));

for (const display of ['block', 'contents']) {
  test(`a control with a colour transition of its own follows the cross-fade, never back (region ${display})`, async ({
    page,
  }) => {
    await open(
      page,
      `<div id="region" style="display: ${display}"><div id="control" class="t-pressable"
        style="width: 40px; height: 40px; background: var(--t-accent)"></div></div>`,
    );
    await page.evaluate((pair) => {
      const { tsuya } = window as unknown as { tsuya: typeof import('../../packages/core/src/index.ts') };
      const region = document.getElementById('region');
      if (region) tsuya.setAccent(region, pair);
    }, PAIR);
    await page.waitForTimeout(1000);
    const target = hex(OTHER.light).slice(0, 3);
    const frames = await paint(
      page,
      () => {
        const { tsuya } = window as unknown as { tsuya: typeof import('../../packages/core/src/index.ts') };
        const region = document.getElementById('region');
        // OTHER, inlined: the function runs in the page
        if (region) tsuya.setAccent(region, { seed: '#7A3FB0', light: '#7A3FB0', dark: '#B07BEA' });
      },
      1200,
    );
    expect(frames.length).toBeGreaterThan(2);
    const back = frames
      .slice(1)
      .filter((frame, i) => distance(frame, target) > distance(frames[i] ?? frame, target) + 12);
    expect(back, `frames: ${JSON.stringify(frames)}`).toEqual([]);
    expect(distance(frames.at(-1) ?? [], target)).toBeLessThan(3);
  });
}
