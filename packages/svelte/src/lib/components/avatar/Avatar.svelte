<!--
  @component
  A person's avatar (DESIGN.md, Avatar): round, the photo, or initials on `fill`, or on a gradient of their
  `colors` in white when white keeps 4.5:1 on the darker colour (checked at runtime; falls back to `fill`
  otherwise). Decorative without `label`.
-->
<script lang="ts">
  import { contrast } from '@tsuya/core';
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children'> {
    /** The photo; the initials show while it loads or if it fails. */
    src?: string;
    /** Shown while there is no photo, it is loading, or it failed. */
    initials?: string;
    /** Its width and height in px. Default 40. */
    size?: number;
    /** A gradient of the person's colours, '#RRGGBB' each; dropped when white would not reach 4.5:1 on the darker one. */
    colors?: [string, string];
    /** The accessible name; decorative when left out. */
    label?: string;
    /** Pinned on the corner; fold its meaning into `label`. */
    badge?: Snippet;
    /** The element. */
    ref?: HTMLDivElement | null;
  }

  let {
    src,
    initials,
    size = 40,
    colors,
    label,
    badge,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  // a new src gets its own chance to load, even one that previously failed
  let failed = $state(false);
  $effect(() => {
    if (src !== undefined) failed = false;
  });

  const showPhoto = $derived(src !== undefined && !failed);
  const gradient = $derived.by(() => {
    if (colors === undefined) return undefined;
    // white on the darker colour, where it reads best
    return Math.max(...colors.map((color) => contrast('#FFFFFF', color))) >= 4.5 ? colors : undefined;
  });
</script>

<div
  bind:this={ref}
  {...rest}
  class={['t-avatar', className]}
  style:--_t-size="{size}px"
  role={!showPhoto && label !== undefined ? 'img' : undefined}
  aria-label={!showPhoto ? label : undefined}
  aria-hidden={!showPhoto && label === undefined ? 'true' : undefined}
>
  <!-- the round clip lives here, separate from the avatar's own box, so a pinned badge can escape it -->
  <div
    class={['t-avatar-circle', gradient !== undefined && 't-avatar-gradient']}
    style:--_t-font-size="{size * 0.36}px"
    style:background={gradient && `linear-gradient(135deg, ${gradient[0]}, ${gradient[1]})`}
  >
    {#if showPhoto}
      <img
        class="t-avatar-img"
        src={src ?? ''}
        alt={label ?? ''}
        width={size}
        height={size}
        decoding="async"
        onerror={() => (failed = true)}
      />
    {:else if initials}
      <span class="t-avatar-initials" aria-hidden="true">{initials}</span>
    {/if}
  </div>
  {#if badge}<span class="t-avatar-badge-pin">{@render badge()}</span>{/if}
</div>
