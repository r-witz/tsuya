// A part that names or describes an overlay, as Dialog.Title does: the overlay points at its id only while it is
// rendered. Dialog and Sheet use it.
import { untrack } from 'svelte';

export class Part {
  readonly id: string;
  // how many are rendered
  #rendered = $state(0);

  /** `required`: on the server, where no effect runs to register it, it is taken as rendered (a dialog's title). */
  constructor(id: string, required = false) {
    this.id = id;
    if (required && typeof document === 'undefined') this.#rendered = 1;
  }

  /** Its id while it is rendered, for `aria-labelledby` or `aria-describedby`. */
  get idref(): string | undefined {
    return this.#rendered > 0 ? this.id : undefined;
  }

  /** The part calls it as it renders, `$effect(() => part.register())`; the returned function, as it goes. */
  register(): () => void {
    untrack(() => this.#rendered++);
    return () => {
      this.#rendered--;
    };
  }
}
