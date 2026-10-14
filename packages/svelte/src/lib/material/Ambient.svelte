<!--
  @component
  The ambient background (DESIGN.md, Ambient background): the leading content's image, scaled, blurred and
  saturated, lighting the top of its Surface at the opacity the engine computed for each mode. A new image
  cross-fades; reduced transparency, high contrast, forced colours and print remove it.
-->
<script lang="ts">
  import { untrack } from 'svelte';

  interface Props {
    /** The image: a 64 to 128 px thumbnail is enough. Null shows none. */
    src: string | null;
    /** The `ambient` of the image's pair; without it, the safe opacity. */
    opacity?: { light: number; dark: number } | undefined;
  }

  let { src, opacity }: Props = $props();

  interface Layer {
    src: string | null;
    opacity: { light: number; dark: number } | undefined;
  }

  // two layers: the one shown, and the one the next image fades in on
  const layers: Layer[] = $state([
    { src: untrack(() => src), opacity: untrack(() => opacity) },
    { src: null, opacity: undefined },
  ]);
  let front = $state(0);

  $effect(() => {
    const next: Layer = { src, opacity };
    untrack(() => {
      const shown = layers[front];
      if (shown?.src === next.src) {
        layers[front] = next;
        return;
      }
      front = 1 - front;
      layers[front] = next;
    });
  });
</script>

<div class="t-ambient" aria-hidden="true">
  {#each layers as layer, i (i)}
    <i
      data-on={i === front && layer.src !== null ? '' : undefined}
      style:background-image={layer.src === null ? undefined : `url(${JSON.stringify(layer.src)})`}
      style:--_t-ambient-light={layer.opacity?.light}
      style:--_t-ambient-dark={layer.opacity?.dark}
    ></i>
  {/each}
</div>
