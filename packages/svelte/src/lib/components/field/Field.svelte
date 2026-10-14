<!--
  @component
  The frame of a form control (DESIGN.md, Field): the label above, the control, then the hint, or the error in its
  place, read with the control. The control snippet gets the id and ARIA to spread on the control; `optional` marks
  the field with the `optional` label (required fields are not marked, only announced).
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';
  import { getLabels } from '../../primitives/labels.ts';
  import type { FieldControlProps } from '../../types.ts';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** The visible label. */
    label: string;
    /** Help text under the field. */
    hint?: string;
    /** The error: it takes the place of the hint and marks the control invalid. */
    error?: string;
    /** Must be filled in; announced as required. */
    required?: boolean;
    /** Marks the field with the `optional` label. */
    optional?: boolean;
    /** The control's id; one is made otherwise. */
    id?: string;
    /** The field's element. */
    ref?: HTMLDivElement | null;
    /** The control, given the props to spread on it. */
    control: Snippet<[FieldControlProps]>;
  }

  let {
    label,
    hint,
    error,
    required = false,
    optional = false,
    id,
    ref = $bindable(null),
    class: className,
    control,
    ...rest
  }: Props = $props();

  const uid = $props.id();
  const labels = getLabels('Field');
  const controlId = $derived(id ?? `${uid}-control`);
  const message = `${uid}-message`;
  const controlProps: FieldControlProps = $derived({
    id: controlId,
    'aria-describedby': error || hint ? message : undefined,
    'aria-invalid': error ? true : undefined,
    'aria-errormessage': error ? message : undefined,
    required: required || undefined,
  });
</script>

<div bind:this={ref} {...rest} class={['t-field', className]}>
  <label class="t-field-label" for={controlId}>
    {label}{#if optional}<span class="t-field-marker">{` ${labels.optional}`}</span>{/if}
  </label>
  {@render control(controlProps)}
  {#if error}
    <p class="t-field-message t-field-error" id={message}><Glyph name="alert" />{error}</p>
  {:else if hint}
    <p class="t-field-message" id={message}>{hint}</p>
  {/if}
</div>
