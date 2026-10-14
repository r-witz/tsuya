<!--
  @component
  The picture of a content (DESIGN.md, Thumbnail): square by default, portrait (2:3) or wide (16:9), with a radius
  that grows with its width. A `fill` placeholder, with an optional icon, shows while it loads or without an image.
  Decorative unless it has `alt`.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** The picture's URL; the placeholder shows while it loads or if it fails. */
    src?: string;
    /** The accessible name; decorative when left out. */
    alt?: string;
    /** Its width in px; the height follows from `ratio`. Default 48. */
    size?: number;
    /** Its proportions; the height follows from `size`. Default 'square'. */
    ratio?: 'square' | 'portrait' | 'wide';
    /** Shown on the placeholder while it loads or without an image. */
    icon?: Snippet;
    /** The element. */
    ref?: HTMLDivElement | null;
  }

  let {
    src,
    alt,
    size = 48,
    ratio = 'square',
    icon,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  // a new src gets its own chance to load, even one that previously failed
  let failed = $state(false);
  $effect(() => {
    if (src !== undefined) failed = false;
  });

  const radius = $derived(size <= 40 ? 'xs' : size <= 64 ? 'sm' : size <= 160 ? 'md' : 'lg');
  const height = $derived(Math.round(ratio === 'portrait' ? size * 1.5 : ratio === 'wide' ? (size * 9) / 16 : size));
</script>

<div
  bind:this={ref}
  {...rest}
  class={['t-thumbnail', `t-thumbnail-${ratio}`, `t-thumbnail-${radius}`, className]}
  style:width="{size}px"
>
  <div class="t-thumbnail-placeholder" aria-hidden="true">
    {#if icon}{@render icon()}{/if}
  </div>
  {#if src !== undefined && !failed}
    <img
      class="t-thumbnail-img"
      {src}
      alt={alt ?? ''}
      width={size}
      {height}
      decoding="async"
      onerror={() => (failed = true)}
    />
  {/if}
</div>
