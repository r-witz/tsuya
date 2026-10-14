<!--
  @component
  A slider (DESIGN.md, Slider): a native range input, drawn as a track filled with the accent from the start (from
  the end in RTL) and a 20 thumb. Arrows move by `step` (a twentieth of the range by default, ArrowLeft increasing in RTL), PageUp and PageDown by
  a tenth (a step when that is more), Home and End to the ends (native range behaviour, PageUp/PageDown overridden to a tenth, a step at least). The
  value is announced as a percentage unless `valueLabel` is given. The focus ring sits on the thumb, around the
  hidden native input, which spans the whole track so a press anywhere on it jumps the value, as native ranges do.
-->
<script lang="ts">
  import type { HTMLInputAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLInputAttributes, 'type' | 'value' | 'min' | 'max' | 'step' | 'children'> {
    /** The current value. */
    value?: number;
    /** The lowest value, 0 by default. */
    min?: number;
    /** The highest value, 1 by default (as Flutter's `Slider`). */
    max?: number;
    /** Default a twentieth of the range. */
    step?: number;
    /** The accessible name, required. */
    label: string;
    /** Formats the announced value; a percentage of the range by default. */
    valueLabel?: (value: number) => string;
    /** The native input. */
    ref?: HTMLInputElement | null;
  }

  let {
    min = 0,
    max = 1,
    value = $bindable((min + max) / 2),
    step,
    label,
    valueLabel,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  const stepValue = $derived(step ?? (max - min) / 20);
  const percent = $derived(((value - min) / (max - min)) * 100);
  const valueText = $derived(valueLabel ? valueLabel(value) : `${String(Math.round(percent))} %`);

  // Arrows follow the visual order, in every browser (WebKit's native range ignores the direction): the end the fill
  // grows from is the low end, so in RTL ArrowLeft increases. PageUp/PageDown move by a tenth of the range;
  // Home and End are native already
  function onkeydown(event: KeyboardEvent) {
    const input = event.currentTarget as HTMLInputElement;
    const before = input.value;
    if (event.key === 'ArrowLeft' || event.key === 'ArrowRight') {
      if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
      event.preventDefault();
      const rtl = getComputedStyle(input).direction === 'rtl';
      if ((event.key === 'ArrowRight') !== rtl) input.stepUp();
      else input.stepDown();
    } else if (event.key === 'PageUp' || event.key === 'PageDown') {
      if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
      event.preventDefault();
      // a tenth, or a step when that is more: a smaller move would snap back to where it was
      const page = Math.max((max - min) / 10, stepValue);
      const delta = event.key === 'PageUp' ? page : -page;
      input.value = String(Math.min(max, Math.max(min, value + delta)));
    } else return;
    if (input.value === before) return;
    // as the native keys do, so `bind:value`, `oninput` and `onchange` follow
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }
</script>

<div class={['t-slider', className]}>
  <input
    bind:this={ref}
    bind:value
    {...rest}
    type="range"
    {min}
    {max}
    step={stepValue}
    aria-label={label}
    aria-valuetext={valueText}
    class="t-slider-input t-pressable"
    data-press="none"
    {onkeydown}
  />
  <span class="t-slider-track">
    <span class="t-slider-fill" style:width="{String(percent)}%"></span>
  </span>
  <span class="t-slider-thumb" style:margin-inline-start="calc({String(percent)}% - var(--_t-thumb-size) / 2)"></span>
</div>
