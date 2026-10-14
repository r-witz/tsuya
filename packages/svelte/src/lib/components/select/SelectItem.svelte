<!--
  @component
  An option of a select (DESIGN.md, Select): a row with its label, ticked when selected; the pointer over it makes it
  active, a press chooses it.
-->
<script lang="ts" generics="T">
  import { onDestroy, type Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Option from '../../internal/Option.svelte';
  import { getGroup, getSelect, SelectEntry } from './state.svelte.ts';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** What `value` becomes when it is chosen. */
    value: T;
    /** Its text, for the trigger and type-ahead. */
    label: string;
    /** Cannot be chosen. */
    disabled?: boolean;
    /** What it shows instead of the label. */
    children?: Snippet;
  }

  let { value, label, disabled = false, children, class: className, ...rest }: Props = $props();

  const select = getSelect('Item');
  const group = getGroup();
  const entry = new SelectEntry({
    get value() {
      return value;
    },
    get label() {
      return label;
    },
    get disabled() {
      return disabled;
    },
    get group() {
      return group?.();
    },
  });
  // registered as it renders, on the server too, so that the trigger has its label
  onDestroy(select.register(entry));

  const index = $derived(select.options.indexOf(entry.option));
  const selected = $derived(value === select.props.value());
</script>

<Option
  bind:ref={entry.node}
  {...rest}
  id={index === -1 ? undefined : select.listbox.idOf(index)}
  {selected}
  active={index !== -1 && select.listbox.active === index}
  {disabled}
  class={['t-select-item', className]}
  onpointermove={() => {
    if (!disabled) select.listbox.move(index);
  }}
  onclick={() => {
    select.listbox.select(index);
  }}
>
  {#if children}{@render children()}{:else}{label}{/if}
</Option>
