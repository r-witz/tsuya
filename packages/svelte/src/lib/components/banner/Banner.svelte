<!--
  @component
  A banner (DESIGN.md, Banner): a lasting state (offline, sync error, trial ending). A status icon, a title, a
  message, and actions at the end, under the message when the banner is narrow. Tones info, success, warning, danger,
  each a fill at 13 % with a 1 px ring at 32 %; never a coloured side stripe. `onclose` adds a close button.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Glyph, { type GlyphName } from '../../internal/Glyph.svelte';
  import { getLabels } from '../../primitives/labels.ts';
  import IconButton from '../button/IconButton.svelte';

  const ICONS: Record<'info' | 'success' | 'warning' | 'danger', GlyphName> = {
    info: 'info',
    success: 'check',
    warning: 'alert',
    danger: 'alert',
  };

  interface Props extends Omit<HTMLAttributes<HTMLDivElement>, 'children' | 'onclose'> {
    /** What kind of message it is: sets its colour and icon. */
    tone: 'info' | 'success' | 'warning' | 'danger';
    /** The headline. */
    title: string;
    /** The message, under the title. */
    children?: Snippet;
    /** Buttons at the end. */
    actions?: Snippet;
    /** Shows a close button; called when it is pressed. */
    onclose?: (event: MouseEvent) => void;
    /** The banner's element. */
    ref?: HTMLDivElement | null;
  }

  let { tone, title, children, actions, onclose, ref = $bindable(null), class: className, ...rest }: Props = $props();

  const labels = getLabels('Banner');
  const uid = $props.id();
  const titleId = `${uid}-title`;
</script>

<div
  bind:this={ref}
  {...rest}
  role="group"
  aria-labelledby={titleId}
  class={['t-banner', `t-banner-${tone}`, className]}
>
  <Glyph name={ICONS[tone]} />
  <div class="t-banner-body">
    <div class="t-banner-row">
      <div class="t-banner-text-col">
        <p class="t-banner-title" id={titleId}>{title}</p>
        {#if children}<div class="t-banner-text">{@render children()}</div>{/if}
      </div>
      {#if actions}<div class="t-banner-actions">{@render actions()}</div>{/if}
    </div>
  </div>
  {#if onclose}
    <IconButton label={labels.close} variant="plain" size="sm" onclick={onclose}>
      {#snippet icon()}<Glyph name="close" />{/snippet}
    </IconButton>
  {/if}
</div>
