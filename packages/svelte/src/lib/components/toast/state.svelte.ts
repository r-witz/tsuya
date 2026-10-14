// The toast's state (DESIGN.md, Toast): one message at a time, anywhere in the app; ToastRegion (TsuyaProvider)
// renders it.

import { announce } from '@tsuya/core/primitives';

// Glyph.svelte's own glyph names: repeated rather than imported, since a plain .ts file linting a type from a
// .svelte file is past what this project's type-aware eslint (unlike tsc and svelte-check) resolves.
export type ToastIcon =
  | 'check'
  | 'minus'
  | 'chevron-down'
  | 'chevron-right'
  | 'back'
  | 'close'
  | 'search'
  | 'alert'
  | 'info'
  | 'eye'
  | 'eye-off';

export interface ToastAction {
  /** The button's text. */
  label: string;
  /** Called when it is pressed. */
  onclick: () => void;
}

export interface ToastOptions {
  /** A glyph before the message, in the accent. */
  icon?: ToastIcon;
  /** A small button; the toast then stays until it is used. */
  action?: ToastAction;
}

export interface ToastData {
  id: number;
  message: string;
  icon?: ToastIcon;
  action?: ToastAction;
}

let next = 0;

export const toastState: { current: ToastData | null } = $state({ current: null });

/** Shows `message`; replaces the toast already shown, if one is. */
export function toast(message: string, options: ToastOptions = {}): void {
  // on the server there is no one to show it to, and the module state is shared by every request
  if (typeof document === 'undefined') return;
  toastState.current = { id: next++, message, icon: options.icon, action: options.action };
  // read through the live region that exists already: a toast added with its text is not read reliably
  announce(message);
}

/** Dismisses the toast `id`, unless it was already replaced. ToastRegion calls it. */
export function dismissToast(id: number): void {
  if (toastState.current?.id === id) toastState.current = null;
}
