<!-- An anchor in a scrolling box, and a floating element anchored to it, taller than the room when `tall`. -->
<script lang="ts">
  import { anchored, type Align, type Side } from '../../../packages/core/src/primitives/anchored.ts';

  interface Props {
    top?: number;
    side?: Side;
    align?: Align;
    dir?: 'ltr' | 'rtl';
    tall?: boolean;
    /** The anchor's scale, as in a press. */
    scale?: number;
  }

  let { top = 100, side, align, dir = 'ltr', tall = false, scale = 1 }: Props = $props();
  let anchor = $state<HTMLElement>();
</script>

<div data-testid="box" {dir} style="position: fixed; inset: 0; overflow: auto">
  <div style="height: 3000px; position: relative">
    <button
      type="button"
      bind:this={anchor}
      style="position: absolute; left: 100px; top: {top}px; width: 100px; height: 40px; scale: {scale}">Anchor</button
    >
    <div
      data-testid="floating"
      style="width: 200px; background: gray; {tall ? 'overflow: auto' : 'height: 150px'}"
      {@attach anchored({ anchor: () => anchor, side, align })}
    >
      {#if tall}<div style="height: 1000px"></div>{/if}
    </div>
  </div>
</div>
