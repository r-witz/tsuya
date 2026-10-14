// Shared helpers for the docs site's Playwright specs, run against the built, prerendered site.
import { fileURLToPath } from 'node:url';

import type { Page } from '@playwright/test';

export { PAGES } from '../../apps/docs/src/lib/content/nav.ts';

const AXE_SCRIPT = fileURLToPath(import.meta.resolve('axe-core/axe.min.js'));

/** Opens a page of the docs and waits until it is hydrated and its fonts are in: what `networkidle` waited for, without
 * its half second of quiet on every load. */
export async function open(page: Page, path: string): Promise<void> {
  await page.goto(path);
  await page.locator('html[data-hydrated]').waitFor({ state: 'attached' });
  await page.evaluate(() => document.fonts.ready);
}

/** Listens from now on, for console errors and warnings and uncaught errors; read the array after navigating. */
export function trackConsoleErrors(page: Page): string[] {
  const errors: string[] = [];
  page.on('console', (message) => {
    if (message.type() === 'error' || message.type() === 'warning') errors.push(message.text());
  });
  page.on('pageerror', (error) => errors.push(String(error)));
  return errors;
}

/** axe-core's violations on the current page, each as "rule: targets", or [] when there are none. */
export async function axeViolations(page: Page): Promise<string[]> {
  await page.addScriptTag({ path: AXE_SCRIPT });
  return page.evaluate(async () => {
    interface AxeNode {
      target: string[];
    }
    interface AxeViolation {
      id: string;
      nodes: AxeNode[];
    }
    interface AxeWindow {
      axe: { run: (context: Document, options: { resultTypes: string[] }) => Promise<{ violations: AxeViolation[] }> };
    }
    const { violations } = await (window as unknown as AxeWindow).axe.run(document, { resultTypes: ['violations'] });
    return violations.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(' ')).join(', ')}`);
  });
}
