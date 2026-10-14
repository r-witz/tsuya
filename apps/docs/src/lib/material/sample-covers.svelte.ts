// The built-in sample covers (./covers.ts), run through the engine once per page load for the Blocks examples: each
// one's picture as a data URL and its accent pair (accentFromImage). Browser only: nothing runs while prerendering,
// `list` is empty until `load()` has run in onMount, so a block that needs covers waits for it.
import { accentFromImage, type ImageAccent } from '@tsuya/core';

import { COVERS, renderCover } from './covers.ts';

export interface SampleCover {
  name: string;
  src: string;
  pair: ImageAccent;
}

class SampleCovers {
  list = $state<SampleCover[]>([]);

  load(): void {
    if (this.list.length > 0) return;
    this.list = COVERS.map((cover) => {
      const canvas = renderCover(cover, 256);
      return { name: cover.name, src: canvas.toDataURL('image/jpeg', 0.9), pair: accentFromImage(canvas) };
    });
  }
}

export const sampleCovers = new SampleCovers();
