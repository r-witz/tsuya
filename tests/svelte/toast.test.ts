// Toast (DESIGN.md, Toast; G5, G6, G9): glass, role="status", bottom centre; one at a time; leaves on its own unless
// it has an action, paused while hovered or focused; Escape, its close button or a swipe down (not an outside press) (on
// touch) dismiss it; F6 reaches it and focus returns; always above a dialog, however the two are opened in turn.
import { flushSync } from 'svelte';
import { afterEach, beforeEach, expect, test, vi } from 'vitest';
import { cdp, page, server, userEvent } from 'vitest/browser';
import { render } from 'vitest-browser-svelte';

import { radius, space } from '../../packages/core/src/tokens.ts';
import { toastState } from '../../packages/svelte/src/lib/components/toast/state.svelte.ts';
import Nested from './fixtures/Nested.svelte';
import Toasts from './fixtures/Toasts.svelte';

const status = (screen: { getByRole: (role: string) => { element: () => Element } }) =>
  screen.getByRole('status').element() as HTMLElement;

function pointer(node: Element, type: string, clientY: number, pointerType = 'touch') {
  node.dispatchEvent(new PointerEvent(type, { pointerId: 1, clientY, pointerType, bubbles: true }));
}

beforeEach(async () => {
  await page.viewport(390, 700);
});

// --t-duration-toast, overridden for a test (the toast portals out to document.body or a dialog, past any wrapper
// a fixture could set it on instead): :root reaches it wherever it ends up.
function dwell(ms: number) {
  document.documentElement.style.setProperty('--t-duration-toast', `${String(ms)}ms`);
}

afterEach(async () => {
  await userEvent.keyboard('{Escape}');
  document.documentElement.style.removeProperty('--t-duration-toast');
  // toastState is a singleton outside any component, so it (and the node it renders, moved out by portal()) would
  // otherwise outlive the fixture a test rendered it in
  toastState.current = null;
});

test('shows the message, a status; glass, min 48 tall, radius-full, its icon in accent', async () => {
  const screen = await render(Toasts, { icon: 'check' });
  await screen.getByRole('button', { name: 'Notify' }).click();
  const toast = status(screen);
  expect(toast.textContent).toContain('Saved');
  expect(toast.classList.contains('t-glass')).toBe(true);
  expect(toast.getAttribute('data-shadow')).toBe('md');
  const style = getComputedStyle(toast);
  expect(parseFloat(style.minHeight)).toBeGreaterThanOrEqual(space['48']);
  expect(style.borderRadius).toBe(`${String(radius.full)}px`);
  const icon = toast.querySelector('.t-glyph') as Element;
  const reference = document.createElement('div');
  reference.style.color = 'var(--t-accent)';
  toast.append(reference);
  expect(getComputedStyle(icon).color).toBe(getComputedStyle(reference).color);
  reference.remove();
});

test('G5: the message is read through the live announcer, which exists before it; the toast itself is not live', async () => {
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  // an element added with its text is not read reliably: the region TsuyaProvider rendered beforehand is
  const live = document.querySelector('[data-tsuya-live="polite"]');
  await expect.poll(() => live?.textContent).toBe('Saved');
  expect(status(screen).getAttribute('aria-live')).toBe('off');
});

test('above the tab bar of a phone screen, centred', async () => {
  const screen = await render(Toasts, { tabBar: true });
  await screen.getByRole('button', { name: 'Notify' }).click();
  const toast = status(screen).getBoundingClientRect();
  const bar = (document.querySelector('.t-tab-bar') as Element).getBoundingClientRect();
  expect(toast.bottom).toBeLessThanOrEqual(bar.top);
  expect(Math.abs(toast.left + toast.width / 2 - 390 / 2)).toBeLessThanOrEqual(1);
});

test('one at a time: a second call replaces the first', async () => {
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  expect(status(screen).textContent).toContain('Saved');
  await screen.getByRole('button', { name: 'Notify again' }).click();
  await new Promise((r) => setTimeout(r, 350));
  expect(screen.getByRole('status').elements()).toHaveLength(1);
  expect(status(screen).textContent).toContain('Also saved');
});

test('without an action, it leaves on its own; paused while hovered, then resumes', async () => {
  // comfortably above a click's own round trip, so a busy run cannot read as an elapsed dwell (caught by a flaky run)
  dwell(300);
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  const toast = status(screen);
  pointer(toast, 'pointerenter', 0, 'mouse');
  await new Promise((r) => setTimeout(r, 150));
  expect(screen.getByRole('status').elements()).toHaveLength(1);
  pointer(toast, 'pointerleave', 0, 'mouse');
  await expect.element(screen.getByRole('status')).not.toBeInTheDocument();
});

test('without an action, it leaves after its dwell', async () => {
  dwell(300);
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  expect(screen.getByRole('status').elements()).toHaveLength(1);
  await expect.element(screen.getByRole('status')).not.toBeInTheDocument();
});

test('with an action: a small ghost button, a close button, stays past its dwell', async () => {
  const onaction = vi.fn();
  dwell(20);
  const screen = await render(Toasts, { withAction: true, onaction });
  await screen.getByRole('button', { name: 'Notify' }).click();
  await new Promise((r) => setTimeout(r, 60));
  expect(screen.getByRole('status').elements()).toHaveLength(1);
  await screen.getByRole('button', { name: 'Undo' }).click();
  expect(onaction).toHaveBeenCalledOnce();
  expect(screen.getByRole('status').elements()).toHaveLength(0);
});

test('with an action: its close button dismisses it without using the action', async () => {
  const onaction = vi.fn();
  const screen = await render(Toasts, { withAction: true, onaction });
  await screen.getByRole('button', { name: 'Notify' }).click();
  await screen.getByRole('button', { name: 'Dismiss' }).click();
  expect(onaction).not.toHaveBeenCalled();
  expect(screen.getByRole('status').elements()).toHaveLength(0);
});

test('Escape dismisses it; a press elsewhere does not (it is due above whatever that press opens)', async () => {
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  await userEvent.keyboard('{Escape}');
  expect(screen.getByRole('status').elements()).toHaveLength(0);
  await screen.getByRole('button', { name: 'Notify' }).click();
  document.body.dispatchEvent(new PointerEvent('pointerdown', { bubbles: true }));
  flushSync();
  expect(screen.getByRole('status').elements()).toHaveLength(1);
});

test('F6 moves focus to it; focus returns to the button once it is gone', async () => {
  const screen = await render(Toasts);
  const button = screen.getByRole('button', { name: 'Notify' }).element() as HTMLElement;
  await screen.getByRole('button', { name: 'Notify' }).click();
  await expect.element(screen.getByRole('status')).not.toHaveFocus();
  await userEvent.keyboard('{F6}');
  await expect.element(screen.getByRole('status')).toHaveFocus();
  await userEvent.keyboard('{Escape}');
  expect(document.activeElement).toBe(button);
});

test('going on its own, it leaves the focus where the user moved it meanwhile', async () => {
  dwell(1500);
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  await expect.element(screen.getByRole('status')).toBeVisible();
  const other = screen.getByRole('button', { name: 'Notify again' }).element() as HTMLElement;
  other.focus();
  await expect.poll(() => toastState.current, { timeout: 4000 }).toBeNull();
  await expect.poll(() => document.querySelector('[role="status"]'), { timeout: 4000 }).toBeNull();
  expect(document.activeElement).toBe(other);
});

test('going while the focus is lost to the page, it gives it back to the control that had it', async () => {
  dwell(1500);
  const screen = await render(Toasts);
  const button = screen.getByRole('button', { name: 'Notify' }).element() as HTMLElement;
  await screen.getByRole('button', { name: 'Notify' }).click();
  await expect.element(screen.getByRole('status')).toBeVisible();
  button.blur();
  await expect.poll(() => document.querySelector('[role="status"]'), { timeout: 4000 }).toBeNull();
  expect(document.activeElement).toBe(button);
});

test('a swipe down dismisses it; a short drag or a mouse does not', async () => {
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  let toast = status(screen);
  const height = toast.getBoundingClientRect().height;
  pointer(toast, 'pointerdown', 0, 'mouse');
  pointer(toast, 'pointermove', height, 'mouse');
  pointer(toast, 'pointerup', height, 'mouse');
  expect(screen.getByRole('status').elements()).toHaveLength(1);
  pointer(toast, 'pointerdown', 0);
  pointer(toast, 'pointermove', height * 0.1);
  pointer(toast, 'pointerup', height * 0.1);
  expect(screen.getByRole('status').elements()).toHaveLength(1);
  toast = status(screen);
  pointer(toast, 'pointerdown', 0);
  pointer(toast, 'pointermove', height * 0.6);
  pointer(toast, 'pointerup', height * 0.6);
  flushSync();
  expect(screen.getByRole('status').elements()).toHaveLength(0);
});

function overlapsADialog(toast: Element): boolean {
  const box = toast.getBoundingClientRect();
  const hit = document.elementFromPoint(box.left + box.width / 2, box.top + box.height / 2);
  return hit === toast || toast.contains(hit);
}

test('sits above a dialog opened before it', async () => {
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Open dialog' }).click();
  // triggered from inside the dialog: a background trigger would be inert, behind its modal backdrop
  await screen.getByRole('button', { name: 'Notify from dialog' }).click();
  expect(overlapsADialog(status(screen))).toBe(true);
});

test('sits above a dialog opened after it', async () => {
  const screen = await render(Toasts);
  await screen.getByRole('button', { name: 'Notify' }).click();
  await screen.getByRole('button', { name: 'Open dialog' }).click();
  expect(overlapsADialog(status(screen))).toBe(true);
});

for (const kind of ['dialog', 'sheet', 'sheet-end'] as const) {
  test(`shown over a ${kind}: at the bottom centre of the window, not placed against the modal box`, async () => {
    await page.viewport(800, 700);
    const screen = await render(Nested, { kind });
    await screen.getByRole('button', { name: 'Notify' }).click();
    const box = status(screen);
    // the modal's entry animation ends first: only a modal at rest (no scale or translate) leaves the toast placed by the window
    await expect.poll(() => (box.parentElement as HTMLElement).getAnimations().length).toBe(0);
    const rect = box.getBoundingClientRect();
    expect(Math.abs(700 - space['16'] - rect.bottom)).toBeLessThan(2);
    expect(Math.abs((rect.left + rect.right) / 2 - 400)).toBeLessThan(2);
  });
}

// The browser's accessibility tree, through the DevTools protocol (Chromium only): is the live region that holds the
// message hidden from assistive technology? Everything outside an open modal dialog is.
async function liveRegionIgnored(text: string): Promise<boolean> {
  const session = cdp();
  await session.send('DOM.enable');
  await session.send('Accessibility.enable');
  interface Node {
    backendNodeId: number;
    attributes?: string[];
    children?: Node[];
    contentDocument?: Node;
  }
  const { root } = (await session.send('DOM.getDocument', { depth: -1, pierce: true })) as { root: Node };
  const regions: Node[] = [];
  const walk = (node: Node) => {
    if (node.attributes?.includes('data-tsuya-live')) regions.push(node);
    for (const child of [...(node.children ?? []), ...(node.contentDocument ? [node.contentDocument] : [])])
      walk(child);
  };
  walk(root);
  for (const region of regions) {
    const { outerHTML } = await session.send('DOM.getOuterHTML', { backendNodeId: region.backendNodeId });
    if (!outerHTML.includes(`>${text}<`)) continue;
    const { nodes } = (await session.send('Accessibility.getPartialAXTree', {
      backendNodeId: region.backendNodeId,
      fetchRelatives: false,
    })) as { nodes: { ignored?: boolean }[] };
    return Boolean(nodes[0]?.ignored);
  }
  throw new Error(`no live region holds "${text}"`);
}

test.skipIf(server.browser !== 'chromium')(
  'shown over a modal dialog, the message is in a live region the accessibility tree does not hide',
  async () => {
    await page.viewport(800, 700);
    const screen = await render(Nested, { kind: 'dialog' });
    await screen.getByRole('button', { name: 'Notify' }).click();
    await expect
      .poll(() =>
        [...document.querySelectorAll('[data-tsuya-live="polite"]')].some((live) => live.textContent === 'Saved'),
      )
      .toBe(true);
    await expect.poll(() => liveRegionIgnored('Saved')).toBe(false);
  },
);
