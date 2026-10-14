// Swipe down: on touch, a drag down moves an element with the finger, then dismisses it past a third of its height or
// on a fling, or snaps back. A sheet's handle and a toast use it.
import type { Attachment } from './attachment.ts';

export interface SwipeOptions {
  /** The element that moves: the one the drag starts on by default. */
  target?: () => HTMLElement | null;
  /** Called once a drag goes far or fast enough. */
  ondismiss: () => void;
}

/** `{@attach swipeDown({ ondismiss })}` where the drag starts. Not a mouse, and not a press on a button inside. */
export function swipeDown(options: SwipeOptions): Attachment<HTMLElement> {
  return (node) => {
    let drag: { target: HTMLElement; y: number; height: number; time: number } | null = null;

    const onpointerdown = (event: PointerEvent) => {
      const target = options.target ? options.target() : node;
      if (event.pointerType === 'mouse' || (event.target as Element).closest('button') || !target) return;
      drag = { target, y: event.clientY, height: target.offsetHeight, time: performance.now() };
      target.style.transition = 'none';
      try {
        node.setPointerCapture(event.pointerId);
      } catch {
        // the pointer is already gone (or, in a test, was never a real one): the drag just ends at the next event
      }
    };
    const onpointermove = (event: PointerEvent) => {
      if (drag) drag.target.style.translate = `0 ${String(Math.max(0, event.clientY - drag.y))}px`;
    };
    const onpointerup = (event: PointerEvent) => {
      if (!drag) return;
      const { target } = drag;
      const distance = Math.max(0, event.clientY - drag.y);
      // a floor well under any real gesture's duration, so a sub-frame event burst cannot read as a fling
      const speed = distance / Math.max(50, performance.now() - drag.time);
      const commit = distance > drag.height / 3 || speed > 0.5;
      drag = null;
      target.style.transition = '';
      if (commit) options.ondismiss();
      target.style.translate = '';
    };

    node.addEventListener('pointerdown', onpointerdown);
    node.addEventListener('pointermove', onpointermove);
    node.addEventListener('pointerup', onpointerup);
    node.addEventListener('pointercancel', onpointerup);
    return () => {
      node.removeEventListener('pointerdown', onpointerdown);
      node.removeEventListener('pointermove', onpointermove);
      node.removeEventListener('pointerup', onpointerup);
      node.removeEventListener('pointercancel', onpointerup);
    };
  };
}
