// Dismissable layer: menus, popovers, selects, comboboxes and tooltips close on Escape, on a press outside
// and when focus leaves them; a toast only on Escape (`outsidePress: false, focusOutside: false`), ambient rather
// than contextual, and still due above a dialog or a sheet opened by some other press on the page. Layers stack in
// the order they open: Escape closes the topmost one only, and a press or focus inside a layer keeps the layers
// under it open.
import type { Attachment } from './attachment.ts';

/** Why a layer asks to close. */
export type DismissReason = 'escape' | 'outside' | 'focus';

export interface DismissableOptions {
  /** Called with the reason; the component closes the layer. */
  ondismiss: (reason: DismissReason) => void;
  /** Elements that count as inside, such as the trigger that toggles the layer. */
  inside?: () => readonly (Element | null | undefined)[];
  /** Close when focus moves out, as a non-modal layer does. Default true; a modal sets false. */
  focusOutside?: boolean;
  /** Close on a press outside, as a non-modal layer does. Default true; a toast, ambient rather than contextual, sets
   * false (it still closes on Escape). */
  outsidePress?: boolean;
}

interface Layer {
  node: HTMLElement;
  options: DismissableOptions;
}

// the open layers, the last on top
const layers: Layer[] = [];

// whether `target` is in layer i, in what counts as inside it, or in a layer opened after it
function within(i: number, target: EventTarget | null): boolean {
  if (!(target instanceof Node)) return false;
  return layers
    .slice(i)
    .some(({ node, options }) => node.contains(target) || (options.inside?.() ?? []).some((e) => e?.contains(target)));
}

function onkeydown(event: KeyboardEvent) {
  const top = layers.at(-1);
  if (event.key !== 'Escape' || event.defaultPrevented || !top) return;
  // the default of Escape would also close a <dialog> under the layer
  event.preventDefault();
  top.options.ondismiss('escape');
}

function onpointerdown(event: PointerEvent) {
  for (const [i, layer] of [...layers.entries()].reverse()) {
    if (within(i, event.target)) break;
    if (layer.options.outsidePress ?? true) layer.options.ondismiss('outside');
  }
}

function onfocusin(event: FocusEvent) {
  for (const [i, layer] of [...layers.entries()].reverse()) {
    if (within(i, event.target)) break;
    if (layer.options.focusOutside ?? true) layer.options.ondismiss('focus');
  }
}

/** `{@attach dismissable({ ondismiss })}` on the layer, while it is open. */
export function dismissable(options: DismissableOptions): Attachment<HTMLElement> {
  return (node) => {
    const layer = { node, options };
    if (layers.length === 0) {
      document.addEventListener('keydown', onkeydown);
      document.addEventListener('pointerdown', onpointerdown, true);
      document.addEventListener('focusin', onfocusin);
    }
    layers.push(layer);
    return () => {
      layers.splice(layers.indexOf(layer), 1);
      if (layers.length === 0) {
        document.removeEventListener('keydown', onkeydown);
        document.removeEventListener('pointerdown', onpointerdown, true);
        document.removeEventListener('focusin', onfocusin);
      }
    };
  };
}
