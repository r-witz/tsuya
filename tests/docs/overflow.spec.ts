// No page of the docs clips or overflows its column: `main` fits its grid
// track, and no text sits past the viewport. The shell is `overflow: clip`, so `document.scrollWidth` hides the
// problem: it is the boxes of the elements that are measured. A block that scrolls on purpose (a table, code) is
// measured as a whole, and must be keyboard-focusable and named.
import { expect, test } from '@playwright/test';

import { PAGES, open } from './support.ts';

const WIDTHS = [375, 768, 1100, 1440];

// one test a page, so that the pages run in parallel and a slow one has its own time
for (const { slug } of PAGES) {
  test(`/${slug}: main fits its track, no text goes past the viewport, a scrolling block is focusable and named`, async ({
    page,
  }) => {
    const problems: string[] = [];
    for (const width of WIDTHS) {
      await page.setViewportSize({ width, height: 900 });
      await open(page, `/${slug}`);
      const found = await page.evaluate(() => {
        const out: string[] = [];
        const viewport = document.documentElement.clientWidth;
        const main = document.querySelector('main.content') as HTMLElement;
        const mainBox = main.getBoundingClientRect();
        const layout = main.parentElement as HTMLElement;
        const track = layout.getBoundingClientRect().width - (getComputedStyle(layout).display === 'grid' ? 240 : 0);
        if (mainBox.right > viewport + 0.5)
          out.push(`main ends at ${String(mainBox.right)}, viewport ${String(viewport)}`);
        if (mainBox.width > track + 0.5) out.push(`main is ${String(mainBox.width)} wide in a ${String(track)} track`);
        const scrolls = (el: Element): boolean => {
          const { overflowX } = getComputedStyle(el);
          return overflowX === 'auto' || overflowX === 'scroll';
        };
        for (const el of main.querySelectorAll('*')) {
          if (!scrolls(el) || el.scrollWidth <= el.clientWidth) continue;
          // a row of tabs, links, buttons or a field holds a stop of its own, and focus scrolls it into view
          if (el.querySelector('[role="tab"], a[href], button, input')) continue;
          const name = el.getAttribute('aria-label') ?? el.getAttribute('aria-labelledby');
          // a code block (<pre>) is focusable by Shiki's own tabindex, and is named by what it holds
          const needsName = el.tagName !== 'PRE';
          if (el.getAttribute('tabindex') !== '0' || (needsName && !name))
            out.push(
              `<${el.tagName.toLowerCase()} class="${el.className}"> scrolls, focusable: ${String(el.getAttribute('tabindex') === '0')}, named: ${String(!!name)}`,
            );
        }
        const walker = document.createTreeWalker(main, NodeFilter.SHOW_TEXT);
        const range = document.createRange();
        for (let node = walker.nextNode(); node; node = walker.nextNode()) {
          if (!node.textContent?.trim()) continue;
          // inside a block that scrolls on purpose, or a frame that clips: the block itself was measured above
          let clipped = false;
          for (let el = node.parentElement; el && el !== main; el = el.parentElement)
            if (scrolls(el) || getComputedStyle(el).overflowX === 'hidden' || getComputedStyle(el).overflowX === 'clip')
              clipped = true;
          if (clipped) continue;
          range.selectNodeContents(node);
          const box = range.getBoundingClientRect();
          if (box.width > 0 && box.right > viewport + 0.5)
            out.push(`text "${node.textContent.trim().slice(0, 30)}" ends at ${String(Math.round(box.right))}`);
        }
        return [...new Set(out)].slice(0, 4);
      });
      for (const f of found) problems.push(`${String(width)}: ${f}`);
    }
    expect(problems).toEqual([]);
  });
}
