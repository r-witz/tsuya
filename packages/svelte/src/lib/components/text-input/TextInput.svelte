<!--
  @component
  A text field (DESIGN.md, TextField, Textarea, Search): a native input in the field box, with leading and trailing
  slots, an optional clear button, and a show-password button for passwords, both named from the labels. The box
  takes `class`; the input takes every other attribute, so that a Field's props reach it.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLInputAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';
  import { getLabels } from '../../primitives/labels.ts';

  interface Props extends Omit<HTMLInputAttributes, 'value' | 'children'> {
    /** The text in the field. */
    value?: string;
    /** An icon or a unit before the text. */
    leading?: Snippet;
    /** An icon or a unit after the text. */
    trailing?: Snippet;
    /** A button that empties the field while it holds text, named with the `clear` label. */
    clearable?: boolean;
    /** For a password, a button that shows it, named with the `showPassword` and `hidePassword` labels. */
    revealable?: boolean;
    /** The input. */
    ref?: HTMLInputElement | null;
  }

  let {
    value = $bindable(''),
    type = 'text',
    leading,
    trailing,
    clearable = false,
    revealable = true,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  const labels = getLabels('TextInput');
  let shown = $state(false);
  const password = $derived(type === 'password');

  function clear() {
    value = '';
    ref?.focus();
  }
</script>

<!-- a press on the box beside the input focuses it too; the keyboard reaches the input itself -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div
  class={['t-text-input', 't-field-box', className]}
  onpointerdown={(event) => {
    if (event.target instanceof Element && !event.target.closest('input, button')) {
      event.preventDefault();
      ref?.focus();
    }
  }}
>
  {#if leading}<span class="t-text-input-slot">{@render leading()}</span>{/if}
  <input bind:this={ref} bind:value {...rest} class="t-text-input-input" type={password && shown ? 'text' : type} />
  {#if clearable && value && !rest.disabled && !rest.readonly}
    <button
      type="button"
      class="t-text-input-action t-pressable"
      data-press="highlight"
      aria-label={labels.clear}
      onclick={clear}
    >
      <Glyph name="close" />
    </button>
  {/if}
  {#if password && revealable}
    <button
      type="button"
      class="t-text-input-action t-pressable"
      data-press="highlight"
      aria-label={shown ? labels.hidePassword : labels.showPassword}
      disabled={rest.disabled}
      onclick={() => (shown = !shown)}
    >
      <Glyph name={shown ? 'eye-off' : 'eye'} />
    </button>
  {/if}
  {#if trailing}<span class="t-text-input-slot">{@render trailing()}</span>{/if}
</div>
