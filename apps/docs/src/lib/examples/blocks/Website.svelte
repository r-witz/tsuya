<!--
  Website: a glass app bar floating 12 from the top (TopBar), and a hero lit by the product's own
  imagery: the album shown in the hero gives the page its accent (the bar's glass is tinted by it) and the light at its
  top. Pick another cover in the hero and all three follow. Below it, rows, never cards. On a narrow screen the bar's
  links fold into its menu by themselves.
-->
<script lang="ts">
  import type { ImageAccent } from '@tsuya/core';
  import { AccentRegion, Ambient, Button, List, ListItem, Surface, Thumbnail, TopBar } from '@tsuya/svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  interface Cover {
    name: string;
    src: string;
    pair: ImageAccent;
  }

  let { covers }: { covers: Cover[] } = $props();

  const SHOWN = ['Ember', 'Reef', 'Dusk', 'Moss'];
  const LINKS = [
    { href: '#features', label: 'Features' },
    { href: '#download', label: 'Download' },
  ];

  let lead = $state(0);
  let width = $state(0);

  const shown = $derived(SHOWN.map((name) => covers.find((c) => c.name === name)).filter((c) => c !== undefined));
  const leading = $derived(shown[lead]);
  // the title is larger once the page is wide enough for it
  const wide = $derived(width >= 800);
</script>

<AccentRegion pair={leading?.pair ?? null} style="display: contents">
  <Surface class="site">
    <Ambient src={leading?.src ?? null} opacity={leading?.pair.ambient} />
    <TopBar links={LINKS}>
      {#snippet start()}
        <span class="brand"
          ><span class="mark"><BlockIcon name="play" /></span><span class="t-title-s">Cadence</span></span
        >
      {/snippet}
      {#snippet end()}<Button variant="ghost" size="sm">Sign in</Button>{/snippet}
    </TopBar>

    <div class="page" bind:clientWidth={width}>
      <section class="hero">
        <p class="t-label muted">Music for Mac, Windows and Linux</p>
        <h1 class={wide ? 't-display-l' : 't-display-s'}>Your music, lit by its own cover.</h1>
        <p class="t-body-l lead">
          Cadence takes its colour from the album you are playing, and lights the room with it. Nothing else on the
          screen competes.
        </p>
        <div class="actions">
          <Button variant="primary" size="lg" id="download">Get Cadence</Button>
          <Button variant="secondary" size="lg">See how it works</Button>
        </div>

        <!-- the product's own imagery: choosing a cover changes the accent and the light of the whole page -->
        <ul class="covers" aria-label="Albums in the product">
          {#each shown as cover, i (cover.name)}
            <li>
              <button
                type="button"
                class="cover t-pressable"
                data-press="none"
                aria-label={cover.name}
                aria-pressed={i === lead}
                onclick={() => (lead = i)}
              >
                <Thumbnail src={cover.src} size={120} />
              </button>
            </li>
          {/each}
        </ul>
      </section>

      <section id="features" aria-labelledby="features-title">
        <h2 id="features-title" class="t-title-l">What it does</h2>
        <List>
          <ListItem
            tall
            title="The accent comes from the cover"
            subtitle="Hue kept, lightness fitted to light and dark"
          >
            {#snippet leading()}<span class="icon"><BlockIcon name="heart" /></span>{/snippet}
          </ListItem>
          <ListItem
            tall
            title="The cover lights the background"
            subtitle="Blurred, and never brighter than the text allows"
          >
            {#snippet leading()}<span class="icon"><BlockIcon name="play" /></span>{/snippet}
          </ListItem>
          <ListItem tall title="Glass only above content" subtitle="Bars, menus and sheets; never on a flat background">
            {#snippet leading()}<span class="icon"><BlockIcon name="library" /></span>{/snippet}
          </ListItem>
        </List>
      </section>

      <footer class="t-small muted">© Cadence. Made with tsuya.</footer>
    </div>
  </Surface>
</AccentRegion>

<style>
  .page {
    max-width: 1200px;
    margin-inline: auto;
    padding: var(--t-space-48) var(--t-space-20) var(--t-space-48);
  }
  .brand {
    display: flex;
    align-items: center;
    gap: var(--t-space-8);
    padding-inline: var(--t-space-8);
  }
  .mark,
  .icon {
    display: grid;
    place-items: center;
    flex: none;
    border-radius: var(--t-radius-full);
  }
  .mark {
    width: var(--t-size-control-sm);
    height: var(--t-size-control-sm);
    background: var(--t-accent);
    color: var(--t-on-accent);
  }
  .mark :global(svg),
  .icon :global(svg) {
    width: var(--t-size-icon);
    height: var(--t-size-icon);
  }
  .icon {
    width: var(--t-size-control-md);
    height: var(--t-size-control-md);
    background: var(--t-fill-strong);
  }
  .muted {
    color: var(--t-text-muted);
  }
  .hero {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-bottom: var(--t-space-64);
    text-align: center;
  }
  .hero h1,
  .hero p {
    margin: 0;
  }
  .hero h1 {
    max-width: 16ch;
    margin-block: var(--t-space-12) var(--t-space-16);
  }
  .lead {
    max-width: 60ch;
  }
  .actions {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: var(--t-space-12);
    margin-block: var(--t-space-32);
  }
  .covers {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: var(--t-space-16);
    margin: 0;
    padding: 0;
    list-style: none;
  }
  .cover {
    display: flex;
    padding: 0;
    border: 0;
    border-radius: var(--t-radius-md);
    background: none;
    box-shadow: var(--t-shadow-lg);
  }
  .cover[aria-pressed='true'] {
    outline: var(--t-state-focus-width) solid var(--t-accent);
    outline-offset: var(--t-state-focus-offset);
  }
  #features h2 {
    margin: 0 0 var(--t-space-12);
  }
  footer {
    margin-top: var(--t-space-48);
    text-align: center;
  }
</style>
