<!--
  A component page's Flutter screenshot: the gallery's golden of the
  component, light and dark side by side, at the phone width it is rendered at (apps/gallery, test/goldens). An
  overlay shows its golden with the overlay open.
-->
<script lang="ts">
  interface Props {
    /** The gallery's id of the component: the golden's file name without its mode. */
    id: string;
  }

  let { id }: Props = $props();

  const urls = import.meta.glob<string>(
    ['../../../../gallery/test/goldens/components/*.png', '../../../../gallery/test/goldens/overlays/*.png'],
    { eager: true, query: '?url', import: 'default' },
  );
  // the golden's own [width, height] (vite.config.ts's png-size), which the images carry: the page does not shift
  // when they load
  const sizes = import.meta.glob<[number, number]>(
    ['../../../../gallery/test/goldens/components/*.png', '../../../../gallery/test/goldens/overlays/*.png'],
    { eager: true, query: '?size', import: 'default' },
  );

  function shot(mode: 'light' | 'dark'): { src: string; width: number; height: number } {
    const file = [`overlays/${id}-open-${mode}.png`, `components/${id}-${mode}.png`]
      .map((name) => `../../../../gallery/test/goldens/${name}`)
      .find((path) => urls[path]);
    if (!file) throw new Error(`the gallery has no golden for "${id}"`);
    const [width, height] = sizes[file] as [number, number];
    return { src: urls[file] as string, width, height };
  }
</script>

<figure class="shots">
  {#each ['light', 'dark'] as const as mode (mode)}
    <img {...shot(mode)} alt="The Flutter gallery's {id} screen, {mode}" loading="lazy" />
  {/each}
  <figcaption class="t-small t-muted">The Flutter gallery, at 390 wide, light and dark (its golden tests).</figcaption>
</figure>

<style>
  .shots {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(min(100%, 240px), 1fr));
    gap: var(--t-space-12);
    margin: 0;
  }
  img {
    width: 100%;
    height: auto;
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
  }
  figcaption {
    grid-column: 1 / -1;
  }
</style>
