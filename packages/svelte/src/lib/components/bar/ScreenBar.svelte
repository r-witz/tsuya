<!--
  @component
  The bar of a pushed screen (DESIGN.md, TopBar, ScreenBar): at least `--t-size-bar` tall, a round back button, the
  title centred in `--t-type-title-m` on one line with an optional `--t-type-caption` line, at most one action at the
  end. The back button is named by `backLabel`.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';
  import IconButton from '../button/IconButton.svelte';

  type Back =
    | {
        /** Shows the round back button; called when it is pressed. */
        onBack: () => void;
        /** The back button's accessible name, required with `onBack`. */
        backLabel: string;
      }
    | { onBack?: undefined; backLabel?: undefined };

  type Props = Omit<HTMLAttributes<HTMLElement>, 'title'> &
    Back & {
      /** The screen's title. */
      title: string;
      /** A caption line under the title. */
      subtitle?: string;
      /** One action at the end. */
      action?: Snippet;
    };

  let { title, subtitle, onBack, backLabel, action, class: className, ...rest }: Props = $props();
</script>

<header {...rest} class={['t-screen-bar', className]}>
  <div class="t-screen-bar-side">
    {#if onBack}
      <IconButton label={backLabel ?? ''} onclick={onBack}>
        {#snippet icon()}<Glyph name="back" />{/snippet}
      </IconButton>
    {/if}
  </div>
  <div class="t-screen-bar-heading">
    <h1 class="t-screen-bar-title">{title}</h1>
    {#if subtitle}<p class="t-screen-bar-subtitle">{subtitle}</p>{/if}
  </div>
  <div class="t-screen-bar-side t-screen-bar-end">{@render action?.()}</div>
</header>
