// Anchored position: a floating element next to its anchor, on a side and with an alignment, `--t-space-4`
// away; it flips to the other side when that one has more room, shifts to stay `--t-space-16` inside the viewport,
// takes the height and the width there is (at the start or end side, the room beside the anchor), and follows scroll and resize. Menus, popovers, selects, comboboxes and tooltips use it.
// Computed here in every browser (CSS anchor positioning is not in all of them).
import type { Attachment } from './attachment.ts';

/** A side of the anchor; start and end follow the writing direction. */
export type Side = 'top' | 'bottom' | 'start' | 'end';

/** Where the floating element lines up along the side: its start, centre or end. */
export type Align = 'start' | 'center' | 'end';

export interface Rect {
  left: number;
  top: number;
  width: number;
  height: number;
}

export interface PlaceOptions {
  side?: Side;
  align?: Align;
  /** Between the anchor and the floating element, in pixels. */
  gap: number;
  /** Kept free at the edges of the viewport, in pixels. */
  margin: number;
  rtl?: boolean;
}

/** Where the floating element goes: its top left corner in the viewport, its side after a flip, its maximum height and width. */
export interface Placement {
  x: number;
  y: number;
  side: Side;
  maxHeight: number;
  /** The viewport less the margin on both sides; at the start or end side, the room there is beside the anchor. */
  maxWidth: number;
}

const clamp = (value: number, low: number, high: number) => Math.max(low, Math.min(value, high));

// the start of a length `size` aligned on the segment [start, start + length]
function line(start: number, length: number, size: number, align: Align, reverse: boolean): number {
  if (align === 'center') return start + (length - size) / 2;
  return (align === 'start') !== reverse ? start : start + length - size;
}

/** The placement of a floating element of `size` next to `anchor` in a viewport of `viewport` (pure). */
export function place(
  anchor: Rect,
  size: { width: number; height: number },
  viewport: { width: number; height: number },
  { side = 'bottom', align = 'start', gap, margin, rtl = false }: PlaceOptions,
): Placement {
  const right = anchor.left + anchor.width;
  const bottom = anchor.top + anchor.height;
  if (side === 'top' || side === 'bottom') {
    const below = viewport.height - margin - bottom - gap;
    const above = anchor.top - gap - margin;
    const flip = side === 'bottom' ? size.height > below && above > below : size.height > above && below > above;
    const chosen = flip ? (side === 'bottom' ? 'top' : 'bottom') : side;
    const maxHeight = Math.max(0, chosen === 'bottom' ? below : above);
    const height = Math.min(size.height, maxHeight);
    const x = line(anchor.left, anchor.width, size.width, align, rtl);
    return {
      x: clamp(x, margin, Math.max(margin, viewport.width - margin - size.width)),
      y: chosen === 'bottom' ? bottom + gap : anchor.top - gap - height,
      side: chosen,
      maxHeight,
      maxWidth: Math.max(0, viewport.width - 2 * margin),
    };
  }
  // start and end: left and right in the writing direction
  const toRight = (side === 'end') !== rtl;
  const roomRight = viewport.width - margin - right - gap;
  const roomLeft = anchor.left - gap - margin;
  const flip = toRight ? size.width > roomRight && roomLeft > roomRight : size.width > roomLeft && roomRight > roomLeft;
  const goesRight = toRight !== flip;
  // with no room for its width on either side it is on the one with more, as wide as the room there is
  const maxWidth = Math.max(0, goesRight ? roomRight : roomLeft);
  const width = Math.min(size.width, maxWidth);
  const maxHeight = Math.max(0, viewport.height - 2 * margin);
  const height = Math.min(size.height, maxHeight);
  const y = line(anchor.top, anchor.height, height, align, false);
  return {
    x: goesRight ? right + gap : anchor.left - gap - width,
    y: clamp(y, margin, Math.max(margin, viewport.height - margin - height)),
    side: flip ? (side === 'end' ? 'start' : 'end') : side,
    maxHeight,
    maxWidth,
  };
}

// the box of an element without its own scale: an anchor coming back from a press as the panel opens, a panel coming
// in; scaled from its centre, as they are
function unscaled(element: Element): Rect {
  const box = element.getBoundingClientRect();
  const [x = 1, y = x] = getComputedStyle(element)
    .scale.split(' ')
    .map((value) => Number(value) || 1);
  const [width, height] = [box.width / x, box.height / y];
  return { left: box.left - (width - box.width) / 2, top: box.top - (height - box.height) / 2, width, height };
}

export interface AnchoredOptions {
  /** The element to sit next to. */
  anchor: () => Element | null | undefined;
  side?: Side;
  align?: Align;
}

/**
 * `{@attach anchored({ anchor: () => trigger })}` on the floating element: fixed in the viewport (a popover or a
 * dialog in the top layer is), with `data-side` set to its side after a flip for its entrance.
 */
export function anchored(options: AnchoredOptions): Attachment<HTMLElement> {
  return (floating) => {
    let frame = 0;
    let live = true;
    const update = () => {
      frame = 0;
      const anchor = options.anchor();
      if (!live || !anchor || !floating.isConnected) return;
      const style = getComputedStyle(floating);
      const px = (name: string) => parseFloat(style.getPropertyValue(name)) || 0;
      // the widest it can be, for its own `max-width` to take (a panel's, a tooltip's): the viewport less the margin on
      // both sides, set before it is measured
      floating.style.setProperty(
        '--_t-anchored-max-width',
        `${String(document.documentElement.clientWidth - 2 * px('--t-space-16'))}px`,
      );
      // the size of its box, not of a scale it is shown at while it comes in, to the fraction of a pixel that keeps it
      // inside the margin; its whole height, past a maximum that clearing would undo its scroll
      const placement = place(
        unscaled(anchor),
        {
          width: unscaled(floating).width,
          height: floating.scrollHeight + px('border-top-width') + px('border-bottom-width'),
        },
        { width: document.documentElement.clientWidth, height: document.documentElement.clientHeight },
        {
          side: options.side,
          align: options.align,
          gap: px('--t-space-4'),
          margin: px('--t-space-16'),
          rtl: getComputedStyle(anchor).direction === 'rtl',
        },
      );
      // at the start or end side, the room beside the anchor when that is less than the width it has
      floating.style.setProperty('--_t-anchored-max-width', `${String(placement.maxWidth)}px`);
      Object.assign(floating.style, {
        position: 'fixed',
        inset: 'auto',
        margin: '0',
        left: `${String(placement.x)}px`,
        top: `${String(placement.y)}px`,
        maxHeight: `${String(placement.maxHeight)}px`,
      });
      floating.dataset['side'] = placement.side;
    };
    const schedule = (event?: Event) => {
      // its own scroll moves nothing
      if (event?.target instanceof Node && floating.contains(event.target)) return;
      if (!frame) frame = requestAnimationFrame(update);
    };
    const resize = new ResizeObserver(() => {
      schedule();
    });
    const anchor = options.anchor();
    if (anchor) resize.observe(anchor);
    resize.observe(floating);
    addEventListener('scroll', schedule, { capture: true, passive: true });
    addEventListener('resize', schedule);
    // placed once the update that attached it is over, before it paints: what shows it in that update (a popover
    // shown by an effect) has, and its size is that of the shown box
    queueMicrotask(update);
    return () => {
      live = false;
      cancelAnimationFrame(frame);
      resize.disconnect();
      removeEventListener('scroll', schedule, { capture: true });
      removeEventListener('resize', schedule);
    };
  };
}
