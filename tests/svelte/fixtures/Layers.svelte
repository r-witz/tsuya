<!-- Two nested layers opened by their triggers, and a modal dialog with a layer inside. -->
<script lang="ts">
  import { dismissable, type DismissReason } from '../../../packages/core/src/primitives/dismissable.ts';
  import { topLayer } from '../../../packages/core/src/primitives/top-layer.ts';

  let { log = () => {} }: { log?: (entry: string) => void } = $props();
  let outer = $state(false);
  let inner = $state(false);
  let dialog = $state(false);
  let menu = $state(false);
  let outerTrigger = $state<HTMLButtonElement>();
  let innerTrigger = $state<HTMLButtonElement>();
  let menuTrigger = $state<HTMLButtonElement>();

  const close = (name: string, set: () => void) => (reason: DismissReason) => {
    log(`${name}: ${reason}`);
    set();
  };
</script>

<button type="button" bind:this={outerTrigger} onclick={() => (outer = !outer)}>Outer</button>
{#if outer}
  <div
    data-testid="outer"
    {@attach dismissable({ ondismiss: close('outer', () => (outer = false)), inside: () => [outerTrigger] })}
  >
    <p>Outer layer</p>
    <button type="button" bind:this={innerTrigger} onclick={() => (inner = !inner)}>Inner</button>
    {#if inner}
      <div
        data-testid="inner"
        {@attach dismissable({ ondismiss: close('inner', () => (inner = false)), inside: () => [innerTrigger] })}
      >
        <button type="button">In inner</button>
      </div>
    {/if}
  </div>
{/if}
<button type="button">Elsewhere</button>
<button type="button" onclick={() => (dialog = true)}>Dialog</button>
{#if dialog}
  <dialog
    aria-label="Settings"
    {@attach topLayer()}
    {@attach dismissable({ ondismiss: close('dialog', () => (dialog = false)), focusOutside: false })}
  >
    <button type="button" bind:this={menuTrigger} onclick={() => (menu = !menu)}>Menu</button>
    {#if menu}
      <div
        data-testid="menu"
        {@attach dismissable({ ondismiss: close('menu', () => (menu = false)), inside: () => [menuTrigger] })}
      >
        <button type="button">Item</button>
      </div>
    {/if}
  </dialog>
{/if}
