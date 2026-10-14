<!--
  @component
  The trigger of a select (DESIGN.md, Select): a field box with the selected label, or the placeholder, and a chevron.
  Focus stays on it while the listbox is open: it points to the active option. Enter, Space and the arrows open; Home
  and End open at the ends; a letter opens at a match. Inside a Field, spread its props.
-->
<script lang="ts">
  import { typed } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import type { HTMLButtonAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';
  import { getSelect } from './state.svelte.ts';

  interface Props extends Omit<HTMLButtonAttributes, 'children'> {
    /** Shown while nothing is selected. */
    placeholder?: string;
    /** From a Field: announced as required, as the root's `required` is. */
    required?: boolean;
    /** What it shows instead of the selected label. */
    children?: Snippet;
    /** The button. */
    ref?: HTMLButtonElement | null;
  }

  let { placeholder, required, children, ref = $bindable(null), class: className, ...rest }: Props = $props();

  const select = getSelect('Trigger');
  const label = $derived(select.selectedLabel);

  $effect(() => {
    select.trigger = ref;
  });

  function onkeydown(event: KeyboardEvent) {
    if (select.open) {
      select.listbox.keydown(event);
      return;
    }
    const at = { ArrowDown: 'selected', ArrowUp: 'selected', Enter: 'selected', ' ': 'selected', Home: 'first' }[
      event.key
    ] as 'selected' | 'first' | undefined;
    if (at || event.key === 'End') {
      event.preventDefault();
      select.show(at ?? 'last');
    } else if (typed(event)) {
      select.show();
      select.listbox.keydown(event);
    }
  }
</script>

<button
  bind:this={ref}
  {...rest}
  type="button"
  disabled={select.props.disabled() || rest.disabled}
  class={['t-select-trigger', 't-field-box', className]}
  role="combobox"
  aria-haspopup="listbox"
  aria-expanded={select.open}
  aria-controls={select.listId}
  aria-activedescendant={select.open ? select.listbox.activeId : undefined}
  aria-required={required || select.props.required() || undefined}
  {onkeydown}
  onkeyup={(event) => {
    // Space chose or opened on keydown: no click after it
    if (event.key === ' ') event.preventDefault();
  }}
  onclick={() => {
    if (select.open) select.close();
    else select.show();
  }}
>
  <span class={['t-select-trigger-value', !label && 't-select-trigger-placeholder']}>
    {#if children}{@render children()}{:else}{label ?? placeholder ?? ''}{/if}
  </span>
  <Glyph name="chevron-down" />
</button>
