<!--
  @component
  The phone shell (DESIGN.md, TabBar, Screen): a surface lit by the ambient background of `ambient`, or the glow, with
  the grain; the content within the safe areas and the side margins (`--t-space-20`); the dock (a tab bar) floating
  at the bottom over the content, which fades into `--t-bg` under it. The page scrolls.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Ambient from '../../material/Ambient.svelte';
  import Glow from '../../material/Glow.svelte';
  import Surface from '../../material/Surface.svelte';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The image of the leading content, which lights the top; without one, the glow. */
    ambient?: string | null;
    /** The `ambient` opacities of the image's pair. */
    ambientOpacity?: { light: number; dark: number };
    /** Where the grain shows: the background only, everything, or off. */
    grain?: 'bg' | 'all' | 'off';
    /** A tab bar. */
    dock?: Snippet;
    /** The page. */
    children: Snippet;
  }

  let { ambient = null, ambientOpacity, grain, dock, class: className, children, ...rest }: Props = $props();
</script>

<Surface {...rest} {grain} class={['t-screen', className]}>
  {#if ambient}<Ambient src={ambient} opacity={ambientOpacity} />{:else}<Glow />{/if}
  <div class="t-screen-content">{@render children()}</div>
  {#if dock}<div class="t-screen-dock">{@render dock()}</div>{/if}
</Surface>
