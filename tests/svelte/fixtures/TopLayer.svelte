<!-- A dialog and a popover in an accent region, under a bar with the highest z-index. -->
<script lang="ts">
  import { topLayer } from '../../../packages/core/src/primitives/top-layer.ts';

  let {
    dialog = false,
    popover = false,
    modal = true,
  }: { dialog?: boolean; popover?: boolean; modal?: boolean } = $props();
</script>

<div data-testid="bar" style="position: fixed; inset: 0; z-index: 2147483647"></div>
<div data-testid="region" class="t-accent" style="--t-accent-light: #7A3FB0; --t-accent-dark: #B07BEA">
  {#if dialog}
    <dialog data-testid="dialog" aria-label="Dialog" {@attach topLayer({ modal })}>
      <p data-testid="in-dialog" style="color: var(--t-accent)">In the dialog</p>
    </dialog>
  {/if}
  {#if popover}
    <div data-testid="popover" {@attach topLayer()}>
      <p data-testid="in-popover" style="color: var(--t-accent)">In the popover</p>
    </div>
  {/if}
</div>
