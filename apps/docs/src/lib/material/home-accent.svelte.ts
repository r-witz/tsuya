// Shared, page-crossing state for the home page's cover picker (the whole page takes its accent and
// ambient): the root layout applies it to the whole shell (TopBar included), the home page is the only one that
// ever sets it. Never touched during prerendering: only onMount and click handlers write to it, so every
// server-rendered page is the neutral, content-less one, and the engine genuinely "runs in the page" in the browser.
import type { ImageAccent } from '@tsuya/core';

class HomeAccent {
  pair = $state<ImageAccent | null>(null);
  src = $state<string | null>(null);

  set(pair: ImageAccent, src: string): void {
    this.pair = pair;
    this.src = src;
  }

  clear(): void {
    this.pair = null;
    this.src = null;
  }
}

export const homeAccent = new HomeAccent();
