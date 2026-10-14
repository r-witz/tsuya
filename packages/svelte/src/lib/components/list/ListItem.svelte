<!--
  @component
  A row of a List (DESIGN.md, List, ListItem, Section): a link, a button, or a plain row, with an optional leading
  icon, avatar or thumbnail, a title and subtitle, and a trailing value or control (a chevron by default when the
  row navigates). `current` bolds the title and sets `aria-current`; `destructive` puts the title in `--t-danger`
  (keep it alone in the last group); `tall` grows the row for an account row; `selected`, in a selectable list, puts
  a tick at the end.
-->
<script lang="ts">
  import { HIDDEN } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';
  import { setRow } from '../../internal/row.ts';
  import { getLabels } from '../../primitives/labels.ts';

  interface Props extends Omit<HTMLAttributes<HTMLElement>, 'children' | 'title' | 'onclick'> {
    /** The main line. */
    title: string;
    /** A second, muted line. */
    subtitle?: string;
    /** Renders a link. */
    href?: string;
    /** Called when it is pressed. */
    onclick?: (event: MouseEvent) => void;
    /** `--t-size-row-tall`, for an account row. */
    tall?: boolean;
    /** The current item: a bold title and `aria-current`. */
    current?: boolean;
    /** Its title in `--t-danger`; keep it alone in the last group. */
    destructive?: boolean;
    /** In a selectable list, whether it is the chosen row: a tick at the end; a pressed button. */
    selected?: boolean;
    /** An icon 20, an avatar 40, or a thumbnail 40 to 48. */
    leading?: Snippet;
    /** A value, or a control; a chevron shows by default when the row has `href`. */
    trailing?: Snippet;
    /** The row's element. */
    ref?: HTMLElement | null;
  }

  let {
    title,
    subtitle,
    href,
    onclick,
    tall = false,
    current = false,
    destructive = false,
    selected,
    leading,
    trailing,
    ref = $bindable(null),
    class: className,
    ...rest
  }: Props = $props();

  const labels = getLabels('ListItem');
  const tag = $derived(href !== undefined ? 'a' : onclick ? 'button' : 'div');
  const interactive = $derived(href !== undefined || onclick !== undefined);

  // a plain row names a label-less Switch in `trailing`, by its title and, as a description, its subtitle
  const uid = $props.id();
  setRow(() =>
    interactive ? undefined : { title: `${uid}-title`, subtitle: subtitle ? `${uid}-subtitle` : undefined },
  );
</script>

<svelte:element
  this={tag}
  bind:this={ref}
  {...rest}
  {href}
  type={tag === 'button' ? 'button' : undefined}
  {onclick}
  class={[
    't-list-item',
    interactive && 't-pressable',
    tall && 't-list-item-tall',
    destructive && 't-list-item-destructive',
    className,
  ]}
  data-press={interactive ? 'highlight' : undefined}
  aria-current={current ? 'true' : undefined}
  aria-pressed={tag === 'button' ? selected : undefined}
>
  {#if leading}<span class="t-list-item-leading">{@render leading()}</span>{/if}
  <span class="t-list-item-main">
    <span class="t-list-item-title" id="{uid}-title">{title}</span>
    {#if subtitle}<span class="t-list-item-subtitle" id="{uid}-subtitle">{subtitle}</span>{/if}
  </span>
  {#if trailing}
    <span class="t-list-item-trailing">{@render trailing()}</span>
  {:else if href !== undefined && !selected}
    <span class="t-list-item-chevron"><Glyph name="chevron-right" /></span>
  {/if}
  {#if selected}
    <Glyph name="check" />
    {#if tag !== 'button'}<span style={HIDDEN}>{labels.selected}</span>{/if}
  {/if}
</svelte:element>
