<!-- A radio group with one tab stop, between two buttons. -->
<script lang="ts">
  import { rovingFocus, type RovingOptions } from '../../../packages/core/src/primitives/roving.ts';

  interface Props {
    items?: string[];
    disabled?: number[];
    selected?: number;
    dir?: 'ltr' | 'rtl';
    options?: Omit<RovingOptions, 'items' | 'onmove'>;
    onmove?: (label: string) => void;
  }

  let {
    items = ['Apple', 'Banana', 'Blueberry', 'Cherry'],
    disabled = [],
    selected = -1,
    dir = 'ltr',
    options = {},
    onmove,
  }: Props = $props();
</script>

<button type="button">Before</button>
<div
  role="radiogroup"
  aria-label="Fruit"
  {dir}
  {@attach rovingFocus({ items: '[role="radio"]', ...options, onmove: (item) => onmove?.(item.textContent) })}
>
  {#each items as item, i (item)}
    <button type="button" role="radio" aria-checked={i === selected} aria-disabled={disabled.includes(i) || undefined}
      >{item}</button
    >
  {/each}
</div>
<button type="button">After</button>
