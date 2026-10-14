<!--
  @component
  A select (DESIGN.md, Select): a choice among more than five options, or options not all seen together. A field with
  its label, hint or error, a trigger that looks like a text field, and a listbox panel anchored under it, in groups.
  Composed: Select.Root, Select.Trigger, Select.Content, Select.Item, Select.Group, Select.Separator.
-->
<script lang="ts" generics="T">
  import type { HTMLButtonAttributes } from 'svelte/elements';

  import Field from '../field/Field.svelte';
  import SelectContent from './SelectContent.svelte';
  import SelectGroup from './SelectGroup.svelte';
  import SelectItem from './SelectItem.svelte';
  import SelectRoot from './SelectRoot.svelte';
  import SelectTrigger from './SelectTrigger.svelte';

  /** An option: its value, its text, and the label of its group, if any. */
  interface Option {
    /** What `value` becomes when it is chosen. */
    value: T;
    /** The text shown. */
    label: string;
    /** Cannot be chosen. */
    disabled?: boolean;
    /** The heading of the group it sits under. */
    group?: string;
  }

  interface Props extends Omit<HTMLButtonAttributes, 'value' | 'children'> {
    /** The chosen option's value. */
    value?: T;
    /** Whether it is open. */
    open?: boolean;
    /** The trigger's accessible name, required. */
    label: string;
    /** The choices. */
    options: readonly Option[];
    /** Shown while nothing is selected. */
    placeholder?: string;
    /** The name the value has in a form. */
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
    /** Below the tablet width, the options open in a sheet rather than a panel. Default true. */
    sheetOnPhone?: boolean;
    /** The trigger. */
    ref?: HTMLButtonElement | null;
  }

  let {
    value = $bindable(),
    open = $bindable(false),
    label,
    options,
    placeholder,
    name,
    disabled = false,
    required = false,
    optional = false,
    hint,
    error,
    sheetOnPhone = true,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  // consecutive options of the same group
  const groups = $derived(
    options.reduce<{ label: string | undefined; options: Option[] }[]>((all, option) => {
      const last = all.at(-1);
      if (last && last.label === option.group) last.options.push(option);
      else all.push({ label: option.group, options: [option] });
      return all;
    }, []),
  );
</script>

<SelectRoot bind:value bind:open {name} {disabled} {required} {label} {sheetOnPhone} items={options}>
  <Field {label} {hint} {error} {required} {optional} class={className}>
    {#snippet control(props)}<SelectTrigger {...rest} {...props} bind:ref {placeholder} />{/snippet}
  </Field>
  <SelectContent>
    {#each groups as group, i (i)}
      {#if group.label}
        <SelectGroup label={group.label}>
          {#each group.options as option (option.value)}
            <SelectItem value={option.value} label={option.label} disabled={option.disabled} />
          {/each}
        </SelectGroup>
      {:else}
        {#each group.options as option (option.value)}
          <SelectItem value={option.value} label={option.label} disabled={option.disabled} />
        {/each}
      {/if}
    {/each}
  </SelectContent>
</SelectRoot>
