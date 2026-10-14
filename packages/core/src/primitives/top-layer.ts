// Top layer: a <dialog> or a popover shown above everything while it stays where it is in the document, so
// that it keeps the accent, the glass scope and the labels of what opened it. Every overlay uses it. A modal dialog
// always paints above a popover in Chromium and Firefox, in either order (checked directly, not assumed): an ambient
// overlay meant to sit above one (the toast) cannot out-rank it by re-entering the top layer. `hosts` lets it instead
// portal into the topmost modal, a plain fixed descendant of it paints above its own backdrop too.
import type { Attachment } from './attachment.ts';

const hosts: HTMLDialogElement[] = [];
let onHostsChange: (() => void) | null = null;

function registerHost(node: HTMLDialogElement): () => void {
  hosts.push(node);
  onHostsChange?.();
  return () => {
    hosts.splice(hosts.indexOf(node), 1);
    onHostsChange?.();
  };
}

/** The topmost open modal dialog or sheet, if any: where an ambient overlay above them portals into. */
export function currentHost(): HTMLDialogElement | undefined {
  return hosts.at(-1);
}

/** Calls `onchange` whenever a modal dialog or sheet opens or closes (`currentHost()` may have changed). */
export function watchHosts(onchange: () => void): () => void {
  onHostsChange = onchange;
  return () => {
    if (onHostsChange === onchange) onHostsChange = null;
  };
}

/**
 * `{@attach topLayer()}` on a <dialog> (modal by default) or on any other element (a manual popover) while it is
 * open; closed again when it goes. A modal dialog also becomes `currentHost()` while it is open.
 */
export function topLayer(options: { modal?: boolean } = {}): Attachment<HTMLElement> {
  return (node) => {
    if (node instanceof HTMLDialogElement) {
      const modal = options.modal ?? true;
      if (!node.open) {
        if (modal) node.showModal();
        else node.show();
      }
      const unregister = modal ? registerHost(node) : undefined;
      return () => {
        // a toast portalled in leaves first, so it is not momentarily hidden by close() below
        unregister?.();
        node.close();
      };
    }
    if (!node.hasAttribute('popover')) node.popover = 'manual';
    if (!node.matches(':popover-open')) node.showPopover();
    return () => {
      if (node.matches(':popover-open')) node.hidePopover();
    };
  };
}
