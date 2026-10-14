<!--
  @component
  A composed select (DESIGN.md, Select): its value, whether it is open, and the native select, out of sight, that
  carries the value in a form and its constraint. Holds Select.Trigger and Select.Content; `items` gives the trigger
  its label before the items render, on the server. Below the tablet width the options open in a sheet, unless
  `sheetOnPhone` is false.
-->
<script lang="ts" generics="T">
  import { HIDDEN } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';

  import { formValue } from '../../internal/form.ts';
  import { SelectState, setSelect } from './state.svelte.ts';

  interface Props {
    /** The chosen value. */
    value?: T;
    /** Whether it is open. */
    open?: boolean;
    /** The name the value has in a form. */
    name?: string;
    /** Cannot be used. */
    disabled?: boolean;
    /** A form needs a value: the trigger says so, and a form does not submit without one. */
    required?: boolean;
    /** The name of the listbox; Select gives its label. */
    label?: string;
    /** Below the tablet width, the options open in a sheet rather than a panel. Default true. */
    sheetOnPhone?: boolean;
    /** The labels of the values, for the trigger before the items render. */
    items?: readonly { value: T; label: string }[];
    /** Its trigger and content. */
    children: Snippet;
  }

  let {
    value = $bindable(),
    open = $bindable(false),
    name,
    disabled = false,
    required = false,
    label,
    sheetOnPhone = true,
    items,
    children,
  }: Props = $props();

  const id = $props.id();
  const select = setSelect(
    new SelectState({
      id,
      value: () => value,
      onchange: (chosen: T) => (value = chosen),
      open: () => open,
      setOpen: (next) => (open = next),
      disabled: () => disabled,
      required: () => required,
      label: () => label,
      sheetOnPhone: () => sheetOnPhone,
      items: () => items,
    }),
  );
</script>

{@render children()}
{#if name || required}
  <!-- the value and its constraint: a form that does not submit without a value takes the focus to the trigger -->
  <select
    {name}
    {required}
    {disabled}
    value={formValue(value)}
    aria-hidden="true"
    tabindex="-1"
    style="{HIDDEN}; pointer-events: none"
    oninvalid={(event) => {
      event.preventDefault();
      select.trigger?.focus();
    }}
  >
    <option value=""></option>
    {#if value !== undefined}<option value={formValue(value)}></option>{/if}
  </select>
{/if}
