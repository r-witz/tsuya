<!--
  @component
  An icon button (DESIGN.md, IconButton): a round icon-only action, named by its label. Filled by default, plain,
  accent for the icon-only primary action, or glass; sm, md, lg, or a size from 40 to 72 for the large primary action.
  As a toggle, `pressed` makes it accent-filled. Its label shows as a tooltip on fine pointers.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLButtonAttributes } from 'svelte/elements';

  import Tooltip from '../tooltip/Tooltip.svelte';

  interface Props extends Omit<HTMLButtonAttributes, 'children' | 'aria-label' | 'aria-pressed'> {
    /** The accessible name, required. */
    label: string;
    /** How it looks: filled, plain, accent or glass. */
    variant?: 'filled' | 'plain' | 'accent' | 'glass';
    /** 32, 44 or 56; a number from 40 to 72 for the large primary action. Default 'md'. */
    size?: 'sm' | 'md' | 'lg' | number;
    /** A toggle: whether it is on. */
    pressed?: boolean;
    /** The label as a tooltip on fine pointers. Default true. */
    tooltip?: boolean;
    /** The icon; the button is named by its `label`. */
    icon: Snippet;
    /** Pinned on the corner; fold its meaning into `label`. */
    badge?: Snippet;
    /** The button. */
    ref?: HTMLButtonElement | null;
  }

  let {
    label,
    variant = 'filled',
    size = 'md',
    pressed,
    tooltip = true,
    type = 'button',
    icon,
    badge,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  // a custom size, kept from 40 to 72: the icon is 38 % of it, at least 18
  const custom = $derived(typeof size === 'number' ? Math.min(72, Math.max(40, size)) : undefined);
</script>

{#snippet button(extra: Record<string | symbol, unknown>)}
  <button
    bind:this={ref}
    {...rest}
    {...extra}
    {type}
    class={[
      't-icon-button',
      't-pressable',
      `t-icon-button-${variant}`,
      typeof size === 'string' && `t-icon-button-${size}`,
      variant === 'glass' && 't-glass-control',
      className,
    ]}
    style:--_t-size={custom === undefined ? undefined : `${String(custom)}px`}
    style:--_t-glyph-size={custom === undefined ? undefined : `${String(Math.max(18, custom * 0.38))}px`}
    aria-label={label}
    aria-pressed={pressed}
  >
    {@render icon()}
    {#if badge}<span class="t-icon-button-badge-pin">{@render badge()}</span>{/if}
  </button>
{/snippet}

{#if tooltip}
  <Tooltip text={label} label trigger={button} />
{:else}
  <!-- eslint-disable-next-line @typescript-eslint/no-confusing-void-expression -- the parser types a local snippet as void -->
  {@render button({})}
{/if}
