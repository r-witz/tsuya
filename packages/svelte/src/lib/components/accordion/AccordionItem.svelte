<!--
  @component
  An item of an accordion (DESIGN.md, Accordion): its header and its content, a hairline above it after the first.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { getAccordion, setItem } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** Identifies the item in the root's `value`. */
    value: string;
    /** Cannot be opened or closed. */
    disabled?: boolean;
    /** Its Trigger and Content. */
    children: Snippet;
  }

  let { value, disabled = false, class: className, children, ...rest }: Props = $props();

  const accordion = getAccordion('Item');
  setItem({ value: () => value, disabled: () => disabled });
  const open = $derived(accordion.isOpen(value));
</script>

<div {...rest} class={['t-accordion-item', className]} data-state={open ? 'open' : 'closed'}>
  {@render children()}
</div>
