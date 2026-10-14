// Helpers of the Svelte browser tests.
import { page } from 'vitest/browser';

/** A computed colour of `element` as #RRGGBB, whether the browser gives it as rgb() or color(srgb …). */
export function hexOf(element: Element, property = 'color'): string {
  const value = getComputedStyle(element).getPropertyValue(property);
  const numbers = (value.match(/[\d.]+/g) ?? []).map(Number).slice(0, 3);
  const bytes = value.startsWith('color(') ? numbers.map((v) => v * 255) : numbers;
  return '#' + bytes.map((v) => Math.round(v).toString(16).padStart(2, '0').toUpperCase()).join('');
}

/** A computed colour of `element` as [r, g, b, a], channels 0..255 and alpha to two decimals. */
export function rgbaOf(element: Element, property = 'color', pseudo?: string): number[] {
  const value = getComputedStyle(element, pseudo).getPropertyValue(property);
  const numbers = (value.match(/[\d.]+/g) ?? []).map(Number);
  const srgb = value.startsWith('color(');
  const [r = 0, g = 0, b = 0] = numbers.slice(0, 3).map((v) => Math.round(srgb ? v * 255 : v));
  const a = numbers[3] ?? 1;
  return [r, g, b, Math.round(a * 100) / 100];
}

/** A token colour, #RRGGBB or #RRGGBBAA, as [r, g, b, a] like rgbaOf gives it. */
export function rgbaOfHex(hex: string): number[] {
  const bytes = (hex.slice(1).match(/../g) ?? []).map((pair) => parseInt(pair, 16));
  const [r = 0, g = 0, b = 0, a = 255] = bytes;
  return [r, g, b, Math.round((a / 255) * 100) / 100];
}

/** The pixels of `element` as the browser painted them, from a screenshot. */
export async function painted(element: Element): Promise<ImageData> {
  const base64 = await page.screenshot({ element, save: false });
  const bitmap = await createImageBitmap(await (await fetch(`data:image/png;base64,${base64}`)).blob());
  const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
  const context = canvas.getContext('2d');
  if (!context) throw new Error('no 2d context');
  context.drawImage(bitmap, 0, 0);
  return context.getImageData(0, 0, bitmap.width, bitmap.height);
}

/** The [r, g, b] of the pixel at a fraction of the width of `image`, in the middle of its height. */
export function pixelAt(image: ImageData, fraction: number): number[] {
  const x = Math.min(image.width - 1, Math.floor(image.width * fraction));
  const i = (Math.floor(image.height / 2) * image.width + x) * 4;
  return [...image.data.slice(i, i + 3)];
}

/** A press on the scrim of `dialog`: a pointer press, then the click it ends in, both on the dialog element itself. */
export function pressScrim(dialog: HTMLDialogElement): void {
  const point = { bubbles: true, clientX: 2, clientY: 2 };
  dialog.dispatchEvent(new PointerEvent('pointerdown', point));
  dialog.dispatchEvent(new MouseEvent('click', point));
}
