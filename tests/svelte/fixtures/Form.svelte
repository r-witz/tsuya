<!-- A form of text fields in their Fields, and a search field. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Field, SearchInput, TsuyaProvider, Textarea, TextInput } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  interface Props {
    labels?: TsuyaLabels;
    error?: string;
    required?: boolean;
    optional?: boolean;
    clearable?: boolean;
    disabled?: boolean;
    glass?: boolean;
    searchSize?: 'sm' | 'md';
    email?: string;
    notes?: string;
  }

  let {
    labels = labelsEn,
    error,
    required,
    optional,
    clearable,
    disabled,
    glass,
    searchSize,
    email = $bindable(''),
    notes = $bindable(''),
  }: Props = $props();
  let password = $state('secret');
  let query = $state('');
</script>

<TsuyaProvider {labels}>
  <!-- a form of DESIGN.md (Patterns): one column, --t-space-16 between fields -->
  <div style="display: flex; flex-direction: column; gap: var(--t-space-16)">
    <Field label="Email" hint="Your work email" {error} {required} {optional} data-testid="email-field">
      {#snippet control(props)}
        <TextInput {...props} bind:value={email} type="email" placeholder="you@company.com" {clearable} {disabled} />
      {/snippet}
    </Field>
    <Field label="Password">
      {#snippet control(props)}<TextInput {...props} bind:value={password} type="password" />{/snippet}
    </Field>
    <Field label="Notes">
      {#snippet control(props)}<Textarea {...props} bind:value={notes} maxRows={4} />{/snippet}
    </Field>
    <SearchInput label="Search" bind:value={query} size={searchSize} {glass} data-testid="search" />
  </div>
</TsuyaProvider>
