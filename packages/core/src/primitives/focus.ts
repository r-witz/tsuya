// Focus scope: a modal keeps Tab inside, gives focus to a marked element or the first one Tab reaches when
// it opens, and gives it back to the opener when it closes. Dialogs, sheets and the command palette use it; inside a
// modal <dialog> the browser makes the page behind inert, and the scope adds the Tab cycle and the return.
import type { Attachment } from './attachment.ts';

export interface FocusScopeOptions {
  /** Keep Tab inside the scope, as a modal does. Default true. */
  trap?: boolean;
  /** Give focus back to the element that had it when the scope closes. Default true. */
  restore?: boolean;
}

const FOCUSABLE = [
  'a[href]',
  'area[href]',
  'button',
  'input',
  'select',
  'textarea',
  'iframe',
  'summary',
  'audio[controls]',
  'video[controls]',
  '[contenteditable]:not([contenteditable="false"])',
  '[tabindex]',
].join(', ');

/** The elements inside `root` that Tab reaches, in document order. */
export function tabbables(root: Element): HTMLElement[] {
  return [...root.querySelectorAll<HTMLElement>(FOCUSABLE)].filter((element) => {
    if (element.tabIndex < 0 || element.matches(':disabled') || element.closest('[inert]')) return false;
    if (!element.checkVisibility({ visibilityProperty: true })) return false;
    // Tab reaches one radio of a group: the checked one
    if (element instanceof HTMLInputElement && element.type === 'radio' && !element.checked && element.name) {
      return !root.querySelector(`input[type="radio"][name="${CSS.escape(element.name)}"]:checked`);
    }
    return true;
  });
}

/**
 * Remembers what has the focus now. The returned function gives it back there, unless it went somewhere else on
 * purpose meanwhile: only if it is still in `scope`, or lost to the page.
 */
export function focusReturn(scope: Element): () => void {
  const opener = document.activeElement;
  return () => {
    const active = document.activeElement;
    const lost = !active || active === document.body || scope.contains(active);
    if (lost && opener instanceof HTMLElement && opener.isConnected) opener.focus();
  };
}

// the open scopes, the last on top: only the topmost one keeps Tab
const scopes: HTMLElement[] = [];

/** `{@attach focusScope()}` on the modal's content. Focus goes to `[autofocus]`, `[data-autofocus]` or the first. */
export function focusScope(options: FocusScopeOptions = {}): Attachment<HTMLElement> {
  return (scope) => {
    const { trap = true, restore = true } = options;
    const giveBack = focusReturn(scope);
    scopes.push(scope);
    // after the other attachments of this update, which may open the dialog that holds the scope
    queueMicrotask(() => {
      if (!scope.isConnected || scope.contains(document.activeElement)) return;
      const first = scope.querySelector<HTMLElement>('[autofocus], [data-autofocus]') ?? tabbables(scope)[0];
      if (first) first.focus();
      else {
        if (!scope.hasAttribute('tabindex')) scope.tabIndex = -1;
        scope.focus();
      }
    });

    const onkeydown = (event: KeyboardEvent) => {
      if (!trap || event.key !== 'Tab' || event.defaultPrevented || scopes.at(-1) !== scope) return;
      const all = tabbables(scope);
      const first = all[0];
      const last = all.at(-1);
      const active = document.activeElement;
      if (!first || !last) event.preventDefault();
      else if (event.shiftKey && (active === first || active === scope)) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && active === last) {
        event.preventDefault();
        first.focus();
      }
    };

    scope.addEventListener('keydown', onkeydown);
    return () => {
      scope.removeEventListener('keydown', onkeydown);
      scopes.splice(scopes.indexOf(scope), 1);
      if (restore) giveBack();
    };
  };
}
