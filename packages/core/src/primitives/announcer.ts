// Live announcer: polite and assertive messages for screen readers, through two aria-live regions.
// TsuyaProvider renders them, so that they exist before the first message; otherwise the first message adds them.
// While a modal dialog or sheet is open everything outside it is inert, live regions included: the message then goes
// to a pair of regions inside the topmost one (primitives/top-layer.ts, `currentHost`), which is not.
import { currentHost } from './top-layer.ts';

/** Visually hidden, still read. */
export const HIDDEN =
  'position: absolute; width: 1px; height: 1px; margin: -1px; overflow: hidden; clip-path: inset(50%); white-space: nowrap';

function region(politeness: 'polite' | 'assertive'): HTMLElement {
  const host = currentHost();
  const found = (host ?? document).querySelector<HTMLElement>(`[data-tsuya-live="${politeness}"]`);
  if (found) return found;
  const created = document.createElement('div');
  created.dataset['tsuyaLive'] = politeness;
  created.setAttribute('aria-live', politeness);
  created.setAttribute('aria-atomic', 'true');
  created.style.cssText = HIDDEN;
  (host ?? document.body).append(created);
  return created;
}

/** Announces `message`; `assertive` interrupts what the screen reader says. The same message twice is read twice. */
export function announce(message: string, { assertive = false }: { assertive?: boolean } = {}): void {
  // on the server (a load function, an SSR render) there is nobody to read it
  if (typeof document === 'undefined') return;
  const live = region(assertive ? 'assertive' : 'polite');
  live.textContent = '';
  // a change of text, a frame later, is what screen readers announce
  requestAnimationFrame(() => {
    live.textContent = message;
  });
}
