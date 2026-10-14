<!--
  @component
  A tab (DESIGN.md, Tabs): its label in `--t-text-muted`; selected, in `--t-text` with a 2 px `--t-accent` bar under
  it. A press selects it.
-->
<script lang="ts">
  import { onDestroy, type Snippet } from 'svelte';
  import type { HTMLButtonAttributes } from 'svelte/elements';

  import { getTabs } from './state.svelte.ts';

  interface Props extends Omit<HTMLButtonAttributes, 'value' | 'children'> {
    /** The tab it selects. */
    value: string;
    /** Cannot be selected. */
    disabled?: boolean;
    /** The button. */
    ref?: HTMLButtonElement | null;
    /** The label. */
    children: Snippet;
  }

  let { value, disabled = false, ref = $bindable(null), class: className, children, ...rest }: Props = $props();

  const tabs = getTabs('Trigger');
  // registered as it renders, on the server too, so that the first tab is selected while there is no value
  onDestroy(
    tabs.register({
      get value() {
        return value;
      },
    }),
  );
  const selected = $derived(tabs.value === value);
</script>

<button
  bind:this={ref}
  {...rest}
  type="button"
  role="tab"
  id={tabs.tabId(value)}
  aria-selected={selected}
  aria-controls={tabs.panelId(value)}
  tabindex={selected ? 0 : -1}
  {disabled}
  data-value={value}
  data-press="highlight"
  class={['t-tab', 't-pressable', className]}
  onclick={() => {
    tabs.select(value);
  }}
>
  {@render children()}
</button>
