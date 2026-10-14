<!--
  Content page: an album. The cover is the content, so the page's accent and its ambient light come from it:
  accentFromImage ran once on the cover (`pair`), AccentRegion sets the accent, Screen lights the top with the cover.
  `covers` are the sample covers of the docs: a picture and its pair each.
-->
<script lang="ts">
  import type { ImageAccent } from '@tsuya/core';
  import {
    AccentRegion,
    Button,
    IconButton,
    List,
    ListItem,
    PageHeader,
    Screen,
    SectionHeader,
    Thumbnail,
  } from '@tsuya/svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  interface Cover {
    name: string;
    src: string;
    pair: ImageAccent;
  }

  let { covers }: { covers: Cover[] } = $props();

  const ALBUMS = [
    { cover: 'Ember', title: 'Slow Burn', artist: 'Nora Vale', year: 2024 },
    { cover: 'Reef', title: 'Tidepool Letters', artist: 'The Salt Choir', year: 2022 },
    { cover: 'Dusk', title: 'Violet Hour', artist: 'Ines Marlow', year: 2025 },
    { cover: 'Moss', title: 'Understory', artist: 'Field Notes', year: 2021 },
    { cover: 'Dawn', title: 'First Light', artist: 'Pale Harbour', year: 2023 },
  ];
  const TRACKS = [
    ['Low Sun', '3:42'],
    ['Paper Lanterns', '4:08'],
    ['Salt and Smoke', '2:57'],
    ['Afterglow', '5:21'],
    ['Quiet Hours', '3:15'],
    ['The Long Way Round', '4:46'],
  ] as const;

  let index = $state(0);
  let liked = $state(false);
  let playing = $state(0);
  let width = $state(0);

  const album = $derived(ALBUMS[index] ?? ALBUMS[0]);
  const cover = $derived(covers.find((c) => c.name === album?.cover) ?? covers[0]);
  // the cover and the text sit side by side when the column is wide enough for both: the container, not the device
  const wide = $derived(width >= 800);
</script>

<!-- the region sets the accent of everything inside; display: contents keeps it out of the layout -->
<AccentRegion pair={cover?.pair ?? null} style="display: contents">
  <Screen ambient={cover?.src} ambientOpacity={cover?.pair.ambient}>
    <div class="page" class:wide bind:clientWidth={width}>
      <header class="hero">
        <div class="cover">
          <Thumbnail src={cover?.src} alt={`${album?.title ?? ''}, cover`} size={240} />
        </div>
        <div class="text">
          <p class="t-label kind">Album</p>
          <PageHeader
            title={album?.title ?? ''}
            subtitle={`${album?.artist ?? ''} · ${String(album?.year)} · 6 tracks · 24 min`}
          />
          <p class="t-body-l description">
            Six songs written over one winter, recorded live in a single room: warm, close and unhurried, made to be
            played start to finish.
          </p>
          <div class="actions">
            <Button variant="primary" onclick={() => (playing = 0)}>
              {#snippet icon()}<BlockIcon name="play" />{/snippet}
              Play
            </Button>
            <IconButton label="Like" pressed={liked} onclick={() => (liked = !liked)}>
              {#snippet icon()}<BlockIcon name="heart" />{/snippet}
            </IconButton>
            <IconButton label="Share">
              {#snippet icon()}<BlockIcon name="share" />{/snippet}
            </IconButton>
            <IconButton label="More">
              {#snippet icon()}<BlockIcon name="more" />{/snippet}
            </IconButton>
          </div>
        </div>
      </header>

      <SectionHeader title="Tracks" count="6" />
      <List>
        {#each TRACKS as [name, length], i (name)}
          <ListItem title={name} current={playing === i} onclick={() => (playing = i)}>
            {#snippet leading()}<span class="number t-small t-tabular">{i + 1}</span>{/snippet}
            {#snippet trailing()}<span class="t-small t-tabular duration">{length}</span>{/snippet}
          </ListItem>
        {/each}
      </List>

      <SectionHeader title="More albums" />
      <ul class="grid">
        {#each ALBUMS as other, i (other.cover)}
          {@const found = covers.find((c) => c.name === other.cover)}
          <li>
            <!-- each item keeps the region of its own cover: its focus ring is in its own accent -->
            <AccentRegion pair={found?.pair ?? null}>
              <button type="button" class="pick t-pressable" aria-current={i === index} onclick={() => (index = i)}>
                <Thumbnail src={found?.src} size={148} />
                <span class="t-body-strong name">{other.title}</span>
                <span class="t-small artist">{other.artist}</span>
              </button>
            </AccentRegion>
          </li>
        {/each}
      </ul>
    </div>
  </Screen>
</AccentRegion>

<style>
  .page {
    max-width: 1200px;
    margin-inline: auto;
    padding-top: var(--t-space-24);
  }
  .hero {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--t-space-24);
    text-align: center;
  }
  .cover {
    border-radius: var(--t-radius-lg);
    box-shadow: var(--t-shadow-lg);
  }
  .text {
    display: flex;
    flex-direction: column;
    align-items: center;
    min-width: 0;
  }
  /* a header takes its container's width from its parent: stretched, it spans the text column instead of collapsing */
  .text :global(.t-page-header) {
    align-self: stretch;
    justify-content: center;
  }
  .kind {
    margin: 0 0 var(--t-space-8);
    color: var(--t-text-muted);
  }
  .description {
    max-width: 60ch;
    margin: var(--t-space-16) 0 0;
  }
  .actions {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    align-items: center;
    gap: var(--t-space-8);
    margin-top: var(--t-space-24);
  }
  /* on a wide column the cover is on the left and the text sits at its bottom */
  .wide .hero {
    flex-direction: row;
    align-items: flex-end;
    text-align: start;
  }
  .wide .text {
    align-items: flex-start;
  }
  .wide .text :global(.t-page-header) {
    justify-content: flex-start;
  }
  .wide .actions {
    justify-content: flex-start;
  }
  .number,
  .duration {
    color: var(--t-text-muted);
  }
  .number {
    min-width: var(--t-space-24);
    text-align: center;
  }
  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(148px, 1fr));
    gap: var(--t-space-24) var(--t-space-16);
    margin: 0;
    padding: 0;
    list-style: none;
  }
  .pick {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: var(--t-space-4);
    width: 100%;
    padding: 0;
    border: 0;
    background: none;
    color: var(--t-text);
    text-align: start;
  }
  .pick[aria-current='true'] .name {
    font-weight: 800;
  }
  .name,
  .artist {
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .artist {
    color: var(--t-text-muted);
  }
</style>
