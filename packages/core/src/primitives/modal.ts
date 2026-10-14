// Modal: a <dialog> shown modal while it is open, in the top layer, with a focus scope that keeps Tab inside and gives
// focus back when it closes; Escape and a press on its scrim ask to close it. Dialog.Content and Sheet.Content use it.
import type { Attachment } from './attachment.ts';

import { dismissable } from './dismissable.ts';
import { focusScope } from './focus.ts';
import { topLayer } from './top-layer.ts';

/** `{@attach open && modal(ondismiss)}` on a <dialog>: `ondismiss` on Escape and on a press on its scrim. */
export function modal(ondismiss: () => void): Attachment<HTMLDialogElement> {
  return (node) => {
    // a press on the scrim: a pointer press that starts on the dialog element itself and ends in a click on it, outside
    // its box. A click from a keyboard activation or from a descendant (a sheet, a menu, a select panel) is not one.
    let pressed = false;
    const onpointerdown = (event: PointerEvent) => {
      pressed = event.target === node;
    };
    const onclick = (event: MouseEvent) => {
      const wasPressed = pressed;
      pressed = false;
      if (!wasPressed || event.target !== node) return;
      const box = node.getBoundingClientRect();
      const inside =
        event.clientX >= box.left &&
        event.clientX <= box.right &&
        event.clientY >= box.top &&
        event.clientY <= box.bottom;
      if (!inside) ondismiss();
    };
    node.addEventListener('pointerdown', onpointerdown);
    node.addEventListener('click', onclick);
    const stops = [
      topLayer({ modal: true }),
      focusScope({ trap: true, restore: true }),
      dismissable({ ondismiss, focusOutside: false }),
    ].map((attach) => attach(node));
    return () => {
      node.removeEventListener('pointerdown', onpointerdown);
      node.removeEventListener('click', onclick);
      for (const stop of stops) stop();
    };
  };
}
