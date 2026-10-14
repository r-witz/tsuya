<!--
  @component
  A text area (DESIGN.md, TextField, Textarea, Search): the field box, at least twice a control's height, growing
  with its content up to `maxRows`, then scrolling. Takes every attribute of a textarea.
-->
<script lang="ts">
  import type { HTMLTextareaAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLTextareaAttributes, 'value'> {
    /** The text in the field. */
    value?: string;
    /** The rows it grows to before it scrolls. Default 8. */
    maxRows?: number;
    /** The textarea. */
    ref?: HTMLTextAreaElement | null;
  }

  let { value = $bindable(''), maxRows = 8, ref = $bindable(null), class: className, ...rest }: Props = $props();

  // the height of its text, up to maxRows lines; empty, its minimum
  function fit(area: HTMLTextAreaElement, text: string) {
    area.style.height = '';
    if (text === '') return;
    const style = getComputedStyle(area);
    const px = (name: string) => parseFloat(style.getPropertyValue(name)) || 0;
    const edges = px('border-top-width') + px('border-bottom-width');
    const max = px('line-height') * maxRows + px('padding-top') + px('padding-bottom') + edges;
    area.style.height = 'auto';
    area.style.height = `${String(Math.min(area.scrollHeight + edges, max))}px`;
  }

  $effect(() => {
    if (ref) fit(ref, value);
  });
</script>

<textarea bind:this={ref} bind:value {...rest} class={['t-textarea', 't-field-box', className]}></textarea>
