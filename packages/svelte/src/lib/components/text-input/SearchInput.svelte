<!--
  @component
  A search field (DESIGN.md, TextField, Textarea, Search): a pill with a search glyph and a clear button, named by its
  label, which it does not show; control glass over content; `sm` or `md`.
-->
<script lang="ts">
  import type { HTMLInputAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';
  import TextInput from './TextInput.svelte';

  interface Props extends Omit<HTMLInputAttributes, 'value' | 'size' | 'type' | 'children'> {
    /** The text in the field. */
    value?: string;
    /** The accessible name, required though not shown. */
    label: string;
    /** Control glass, over artwork or content. */
    glass?: boolean;
    /** Its height. */
    size?: 'sm' | 'md';
    /** A button that empties the field while it holds text. Default true. */
    clearable?: boolean;
    /** The input. */
    ref?: HTMLInputElement | null;
  }

  let {
    value = $bindable(''),
    label,
    glass = false,
    size = 'md',
    clearable = true,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();
</script>

<TextInput
  bind:value
  bind:ref
  {...rest}
  type="search"
  aria-label={label}
  {clearable}
  class={['t-search', size === 'sm' && 't-search-sm', glass && 't-glass-control', className]}
>
  {#snippet leading()}<Glyph name="search" />{/snippet}
</TextInput>
