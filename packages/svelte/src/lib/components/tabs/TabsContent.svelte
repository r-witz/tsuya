<!--
  @component
  The panel of a tab (DESIGN.md, Tabs), named by its tab; only the selected one shows, and only its content renders.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { getTabs } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The tab it belongs to. */
    value: string;
    /** The panel content. */
    children: Snippet;
  }

  let { value, class: className, children, ...rest }: Props = $props();

  const tabs = getTabs('Content');
  const selected = $derived(tabs.value === value);
</script>

<div
  {...rest}
  role="tabpanel"
  id={tabs.panelId(value)}
  aria-labelledby={tabs.tabId(value)}
  tabindex="0"
  hidden={!selected}
  class={['t-tabs-content', className]}
>
  {#if selected}{@render children()}{/if}
</div>
