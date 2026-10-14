<!--
  @component
  A combobox (DESIGN.md, Combobox): a text field that filters a list of options in a panel under it. The arrows move
  the active option, Enter chooses it; Escape closes, then clears. Options that load show a spinner and the `loading`
  label, no match shows `noResults`, and the number of results is announced when typing pauses. With `freeText` any
  text stays; otherwise, when focus leaves, a text that names an option chooses it and any other goes back to the
  label of the value.
-->
<script lang="ts" generics="T">
  import { announce, TYPEAHEAD_TIMEOUT } from '@tsuya/core/primitives';
  import { untrack } from 'svelte';
  import type { HTMLInputAttributes } from 'svelte/elements';

  import { formValue } from '../../internal/form.ts';
  import Option from '../../internal/Option.svelte';
  import Panel from '../../internal/Panel.svelte';
  import { getLabels } from '../../primitives/labels.ts';
  import { Listbox } from '../../primitives/listbox.svelte.ts';
  import Field from '../field/Field.svelte';
  import Spinner from '../spinner/Spinner.svelte';
  import TextInput from '../text-input/TextInput.svelte';

  /** An option: its value and its text. */
  interface ComboboxOption {
    /** What `value` becomes when it is chosen. */
    value: T;
    /** The text shown. */
    label: string;
    /** Cannot be chosen. */
    disabled?: boolean;
  }

  interface Props extends Omit<HTMLInputAttributes, 'value' | 'children' | 'type'> {
    /** The chosen option's value. */
    value?: T;
    /** The text in the field. */
    inputValue?: string;
    /** Whether it is open. */
    open?: boolean;
    /** The field's accessible name, required. */
    label: string;
    /** The choices. */
    options: readonly ComboboxOption[];
    /**
     * Whether an option matches the text. By default its label contains the text, ignoring case; `() => true` for
     * options a server has already filtered.
     */
    filter?: (option: ComboboxOption, text: string) => boolean;
    /** The options are loading: a spinner and the `loading` label show in their place. */
    loading?: boolean;
    /** Any text may stay in the field; the value is then undefined unless an option is chosen. */
    freeText?: boolean;
    /** The name of the hidden input that carries the value (or the free text) in a form. */
    name?: string;
    /** Cannot be used. */
    disabled?: boolean;
    /** Must be filled in; announced as required. */
    required?: boolean;
    /** Marked with the `optional` label. */
    optional?: boolean;
    /** Help text under the field. */
    hint?: string;
    /** The error message; marks the field invalid. */
    error?: string;
    /** The input. */
    ref?: HTMLInputElement | null;
  }

  let {
    value = $bindable(),
    inputValue = $bindable(''),
    open = $bindable(false),
    label,
    options,
    filter = (option, text) => option.label.toLocaleLowerCase().includes(text.toLocaleLowerCase()),
    loading = false,
    freeText = false,
    name,
    disabled = false,
    required = false,
    optional = false,
    hint,
    error,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  const id = $props.id();
  const listId = `${id}-listbox`;
  const labels = getLabels('Combobox');

  // the label of the value among the options
  const valueLabel = $derived(
    value === undefined ? undefined : options.find((option) => option.value === value)?.label,
  );
  // the label of the value as last known: options that load may no longer hold it
  const initial = untrack(() => valueLabel) ?? '';
  let known = $state(initial);
  if (!inputValue) inputValue = initial;
  // the text typed since the field last showed the value; null while it shows it, and every option is listed
  let query = $state<string | null>(null);

  const filtered = $derived.by(() => {
    const text = query?.trim();
    return text ? options.filter((option) => filter(option, text)) : options;
  });

  const listbox = new Listbox<T>({
    id,
    options: () => filtered,
    value: () => (value === undefined ? [] : [value]),
    onchange: ([chosen]) => {
      const option = filtered.find((each) => each.value === chosen);
      if (option) choose(option);
    },
    field: true,
  });

  // a value set from outside shows its label, unless the text is being edited
  $effect.pre(() => {
    const label = valueLabel;
    if (label === undefined) return;
    known = label;
    if (query === null) inputValue = label;
  });

  function choose(option: ComboboxOption) {
    value = option.value;
    known = option.label;
    inputValue = option.label;
    query = null;
    open = false;
  }

  function show(at: 'first' | 'last' | null = null) {
    if (disabled) return;
    open = true;
    listbox.active = -1;
    const selected = query === null ? filtered.findIndex((option) => option.value === value) : -1;
    if (selected !== -1) listbox.move(selected);
    else if (at) listbox.move(at);
  }

  // when focus leaves: a text that names an option chooses it; otherwise free text stays, other text goes back
  function commit() {
    query = null;
    if (value !== undefined && inputValue === known) return;
    const text = inputValue.trim().toLocaleLowerCase();
    const match = text ? options.find((option) => !option.disabled && option.label.toLocaleLowerCase() === text) : null;
    if (match) choose(match);
    else if (freeText || !text) {
      value = undefined;
      known = '';
      if (!text) inputValue = '';
    } else inputValue = known;
  }

  function onkeydown(event: KeyboardEvent) {
    // the keys of an IME composition (its Enter included) belong to the IME
    if (event.isComposing) return;
    if (event.key === 'Escape') {
      // open, the panel closes itself; closed, Escape clears, and goes on to a dialog once the field is empty
      if (!open && inputValue) {
        event.preventDefault();
        value = undefined;
        known = '';
        inputValue = '';
        query = null;
      }
    } else if (!open && (event.key === 'ArrowDown' || event.key === 'ArrowUp')) {
      event.preventDefault();
      show(event.key === 'ArrowDown' ? 'first' : 'last');
    } else if (open && !listbox.keydown(event) && event.key === 'Enter') {
      // no active option: the text as it is, and the form's own Enter
      commit();
      open = false;
    }
  }

  $effect(() => {
    if (!open) listbox.active = -1;
  });

  $effect(() => {
    const id = listbox.activeId;
    if (open && id) document.getElementById(id)?.scrollIntoView({ block: 'nearest' });
  });

  // the number of results, once typing pauses
  $effect(() => {
    if (!open) return;
    const message = loading
      ? labels.loading
      : filtered.length === 0
        ? labels.noResults
        : labels.results(filtered.length);
    const timer = setTimeout(() => {
      announce(message);
    }, TYPEAHEAD_TIMEOUT);
    return () => {
      clearTimeout(timer);
    };
  });
</script>

<Field {label} {hint} {error} {required} {optional} class={['t-combobox', className]}>
  {#snippet control(props)}
    <TextInput
      {...rest}
      {...props}
      bind:ref
      bind:value={inputValue}
      role="combobox"
      aria-autocomplete="list"
      aria-expanded={open}
      aria-controls={listId}
      aria-activedescendant={open ? listbox.activeId : undefined}
      autocomplete="off"
      {disabled}
      {onkeydown}
      oninput={(event: Event & { currentTarget: HTMLInputElement }) => {
        query = event.currentTarget.value;
        show();
      }}
      onclick={() => {
        if (!open) show();
      }}
      onblur={() => {
        commit();
        open = false;
      }}
    />
  {/snippet}
</Field>
<Panel
  open={open && !disabled}
  anchor={() => ref?.closest<HTMLElement>('.t-text-input')}
  ondismiss={() => {
    open = false;
  }}
  class="t-combobox-panel"
  tabindex={-1}
  onmousedown={(event: MouseEvent) => {
    // a press in the panel keeps the focus in the field
    event.preventDefault();
  }}
>
  {#if loading}
    <div class="t-combobox-status"><Spinner size="sm" aria-hidden="true" />{labels.loading}</div>
  {:else if filtered.length === 0}
    <div class="t-combobox-status">{labels.noResults}</div>
  {/if}
  <div role="listbox" id={listId} aria-label={label}>
    {#if !loading}
      {#each filtered as option, index (index)}
        <Option
          id={listbox.idOf(index)}
          selected={value !== undefined && option.value === value}
          active={listbox.active === index}
          disabled={option.disabled}
          onpointermove={() => {
            if (!option.disabled) listbox.move(index);
          }}
          onclick={() => {
            listbox.select(index);
          }}>{option.label}</Option
        >
      {/each}
    {/if}
  </div>
</Panel>
{#if name}<input type="hidden" {name} value={value === undefined && freeText ? inputValue : formValue(value)} />{/if}
