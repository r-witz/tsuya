<!--
  @component
  The header of an accordion item (DESIGN.md, Accordion): a row in a heading, a button with its expanded state and a
  chevron that turns over when open. Enter and Space toggle it.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLButtonAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';
  import { getAccordion, getItem } from './state.svelte.ts';

  interface Props extends Omit<HTMLButtonAttributes, 'children'> {
    /** The level of the heading around it. Default 3. */
    level?: 2 | 3 | 4 | 5 | 6;
    /** The button. */
    ref?: HTMLButtonElement | null;
    /** The heading the item opens from. */
    children: Snippet;
  }

  let { level = 3, ref = $bindable(null), class: className, children, ...rest }: Props = $props();

  const accordion = getAccordion('Trigger');
  const item = getItem('Trigger');
  const open = $derived(accordion.isOpen(item.value()));
</script>

<svelte:element this={`h${String(level)}`} class="t-accordion-heading">
  <button
    bind:this={ref}
    {...rest}
    type="button"
    id={accordion.triggerId(item.value())}
    aria-expanded={open}
    aria-controls={accordion.contentId(item.value())}
    disabled={item.disabled()}
    data-press="highlight"
    class={['t-accordion-trigger', 't-pressable', className]}
    onclick={() => {
      accordion.toggle(item.value());
    }}
  >
    <span class="t-accordion-trigger-title">{@render children()}</span>
    <Glyph name="chevron-down" />
  </button>
</svelte:element>
