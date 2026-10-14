// The props of a Button (DESIGN.md, Button), in a module of their own for the components that pass them on, as the
// opener of a menu.
import type { Snippet } from 'svelte';
import type { HTMLAnchorAttributes, HTMLButtonAttributes } from 'svelte/elements';

type Shared = Omit<HTMLButtonAttributes & HTMLAnchorAttributes, 'type' | 'children' | 'onclick'>;

export interface ButtonProps extends Shared {
  /** The emphasis of the button. */
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger' | 'glass';
  /** Its height. */
  size?: 'sm' | 'md' | 'lg';
  /** The full width of its container. */
  block?: boolean;
  /** Shows a spinner in place of the label and ignores presses. */
  loading?: boolean;
  /** Cannot be pressed. */
  disabled?: boolean;
  /** Renders a link. */
  href?: string;
  /** Default 'button'. */
  type?: 'button' | 'submit' | 'reset';
  /** Called when it is pressed. */
  onclick?: (event: MouseEvent) => void;
  /** An icon before the label. */
  icon?: Snippet;
  /** The label. */
  children?: Snippet;
  /** The button or link. */
  ref?: HTMLButtonElement | HTMLAnchorElement | null;
}
