// The arrows of a group of native radios (WAI-ARIA radio group): the next or previous radio that is not
// disabled, in the visual order, wrapping, checked and focused. Chromium and Firefox do it; WebKit neither wraps nor
// follows the writing direction, so every browser gets this one.
import type { Attachment } from 'svelte/attachments';

export const radioArrows: Attachment<HTMLElement> = (group) => {
  const onkeydown = (event: KeyboardEvent) => {
    const radio = event.target;
    if (!(radio instanceof HTMLInputElement) || radio.type !== 'radio') return;
    if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
    const rtl = getComputedStyle(radio).direction === 'rtl';
    const steps: Record<string, number> = {
      ArrowDown: 1,
      ArrowUp: -1,
      ArrowRight: rtl ? -1 : 1,
      ArrowLeft: rtl ? 1 : -1,
    };
    const step = steps[event.key];
    if (step === undefined) return;
    const radios = [...group.querySelectorAll<HTMLInputElement>('input[type="radio"]')].filter(
      (each) => each.name === radio.name && !each.disabled,
    );
    const next = radios[(radios.indexOf(radio) + step + radios.length) % radios.length];
    event.preventDefault();
    if (!next || next === radio) return;
    next.focus();
    // checks it and sends input and change, as the native arrows do
    next.click();
  };
  group.addEventListener('keydown', onkeydown);
  return () => {
    group.removeEventListener('keydown', onkeydown);
  };
};
