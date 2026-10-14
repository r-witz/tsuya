<!-- A switch with its own label (or, by `variant`, in a row, with an aria-label, or with no name at all). -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { ListItem, Switch, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    checked?: boolean;
    disabled?: boolean;
    dir?: 'ltr' | 'rtl';
    /** `label`: its own visible label; `row`: no label, in a ListItem; `aria`: an `aria-label` only; `bare`: no name. */
    variant?: 'label' | 'row' | 'aria' | 'bare';
  }

  let { checked = $bindable(false), disabled = false, dir = 'ltr', variant = 'label' }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="padding: var(--t-space-16)">
    {#if variant === 'row'}
      <ListItem title="Wi-Fi" subtitle="Connected">
        {#snippet trailing()}<Switch bind:checked name="wifi" {disabled} />{/snippet}
      </ListItem>
    {:else if variant === 'aria'}
      <Switch bind:checked name="wifi" aria-label="Wi-Fi" {disabled} />
    {:else if variant === 'bare'}
      <Switch bind:checked name="wifi" {disabled} />
    {:else}
      <Switch bind:checked name="wifi" label="Wi-Fi" {disabled} />
    {/if}
  </div>
</TsuyaProvider>
