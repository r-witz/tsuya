<!--
  @component
  A button (DESIGN.md, Button): a pill with a one-line label and an optional icon; primary for the one accent action
  of a screen, secondary by default, ghost, danger, or glass over artwork. A link with `href`. Loading, a spinner
  takes the icon's place (or comes before the label), the button keeps its width, is busy and ignores presses.
-->
<script lang="ts">
  import { untrack } from 'svelte';

  import Spinner from '../spinner/Spinner.svelte';
  import type { ButtonProps } from './types.ts';

  let {
    variant = 'secondary',
    size = 'md',
    block = false,
    loading = false,
    disabled = false,
    href,
    type = 'button',
    icon,
    children,
    onclick,
    ref = $bindable(null),
    class: className,
    ...rest
  }: ButtonProps = $props();

  // the width before loading, kept while it loads: its layout width, not the scale of a press. Measured before the
  // DOM changes, which a derived value cannot promise.
  // eslint-disable-next-line svelte/prefer-writable-derived
  let width = $state<number>();
  $effect.pre(() => {
    width = loading ? untrack(() => width ?? (ref ? parseFloat(getComputedStyle(ref).width) : undefined)) : undefined;
  });

  const classes = $derived([
    't-button',
    't-pressable',
    `t-button-${variant}`,
    `t-button-${size}`,
    variant === 'glass' && 't-glass-control',
    block && 't-button-block',
    className,
  ]);
</script>

<svelte:element
  this={href === undefined ? 'button' : 'a'}
  bind:this={ref}
  {...rest}
  type={href === undefined ? type : undefined}
  disabled={href === undefined ? disabled : undefined}
  href={disabled ? undefined : href}
  role={href !== undefined && disabled ? 'link' : undefined}
  aria-disabled={(href !== undefined && disabled) || undefined}
  aria-busy={loading || undefined}
  data-press={loading ? 'none' : undefined}
  class={classes}
  style:width={width === undefined ? undefined : `${String(width)}px`}
  onclick={(event: MouseEvent) => {
    if (loading || disabled) {
      event.preventDefault();
      return;
    }
    onclick?.(event);
  }}
>
  {#if loading}<Spinner {size} aria-hidden="true" />{:else if icon}{@render icon()}{/if}
  {#if children}<span class="t-button-label">{@render children()}</span>{/if}
</svelte:element>
