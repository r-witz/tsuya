<!--
  @component
  An accordion (DESIGN.md, Accordion): rows that open their content below, one at a time or several. Holds
  Accordion.Item, each with its Accordion.Trigger and Accordion.Content; `value` holds the values of the open items.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { AccordionState, setAccordion } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** One item open at a time, or several. Default 'single'. */
    type?: 'single' | 'multiple';
    /** The values of the open items. */
    value?: string[];
    /** Its items. */
    children: Snippet;
  }

  let { type = 'single', value = $bindable([]), class: className, children, ...rest }: Props = $props();

  const id = $props.id();
  setAccordion(
    new AccordionState({
      id,
      type: () => type,
      value: () => value,
      setValue: (next) => (value = next),
    }),
  );
</script>

<div {...rest} class={['t-accordion', className]}>
  {@render children()}
</div>
