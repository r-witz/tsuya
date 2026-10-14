<!--
  Desktop shell: a sidebar instead of the tab bar, 240 wide and collapsible to its icons (72), and a
  content column of at most 1200. The "player" is the showcase again: the cover leads, so it gives the accent and the
  light of the ambient background; the controls over the cover are control glass, and the player bar floats as glass
  above the content that scrolls under it. Three glass layers at most: the bar and the two controls.
-->
<script lang="ts">
  import type { ImageAccent } from '@tsuya/core';
  import {
    AccentRegion,
    Ambient,
    IconButton,
    List,
    ListItem,
    Sidebar,
    SidebarGroup,
    SidebarItem,
    Slider,
    Surface,
    Thumbnail,
  } from '@tsuya/svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  interface Cover {
    name: string;
    src: string;
    pair: ImageAccent;
  }

  let { covers }: { covers: Cover[] } = $props();

  // title, artist, cover, length
  const TRACKS = [
    ['Low Sun', 'Nora Vale', 'Ember', '3:42'],
    ['Tidepool Letters', 'The Salt Choir', 'Reef', '4:08'],
    ['Violet Hour', 'Ines Marlow', 'Dusk', '3:21'],
    ['Understory', 'Field Notes', 'Moss', '4:23'],
  ] as const;

  let index = $state(0);
  let playing = $state(false);
  let liked = $state(false);
  let volume = $state(0.7);
  let folded = $state(false);
  let section = $state('library');
  let width = $state(0);

  const track = $derived(TRACKS[index] ?? TRACKS[0]);
  const cover = $derived(covers.find((c) => c.name === track[2]));
  // narrower than the sidebar and a readable column together, the sidebar shows its icons only
  const collapsed = $derived(folded || width < 800);
</script>

{#snippet home()}<BlockIcon name="home" />{/snippet}
{#snippet library()}<BlockIcon name="library" />{/snippet}
{#snippet search()}<BlockIcon name="search" />{/snippet}
{#snippet playlist()}<BlockIcon name="list" />{/snippet}

<AccentRegion pair={cover?.pair ?? null} style="display: contents">
  <Surface class="shell">
    <Ambient src={cover?.src ?? null} opacity={cover?.pair.ambient} />
    <div class="layout" bind:clientWidth={width}>
      <Sidebar {collapsed} aria-label="Library" class="side">
        <SidebarItem icon={home} current={section === 'home'} onclick={() => (section = 'home')}>Home</SidebarItem>
        <SidebarItem icon={search} current={section === 'search'} onclick={() => (section = 'search')}>
          Search
        </SidebarItem>
        <SidebarGroup label="Library">
          <SidebarItem icon={library} count={4} current={section === 'library'} onclick={() => (section = 'library')}>
            Albums
          </SidebarItem>
        </SidebarGroup>
        <SidebarGroup label="Playlists">
          <SidebarItem icon={playlist} count={12} onclick={() => (section = 'evening')}>Evening</SidebarItem>
          <SidebarItem icon={playlist} count={31} onclick={() => (section = 'focus')}>Focus</SidebarItem>
        </SidebarGroup>
        <div class="fold">
          <IconButton
            label={collapsed ? 'Expand the sidebar' : 'Collapse the sidebar'}
            variant="plain"
            size="sm"
            pressed={collapsed}
            onclick={() => (folded = !folded)}
          >
            {#snippet icon()}<BlockIcon name="grid" />{/snippet}
          </IconButton>
        </div>
      </Sidebar>

      <div class="column">
        <header class="hero">
          <div class="art">
            <Thumbnail src={cover?.src} alt={`${track[0]}, cover`} size={232} />
            <div class="over">
              <IconButton label="Like" variant="glass" pressed={liked} onclick={() => (liked = !liked)}>
                {#snippet icon()}<BlockIcon name="heart" />{/snippet}
              </IconButton>
              <IconButton label="More" variant="glass">
                {#snippet icon()}<BlockIcon name="more" />{/snippet}
              </IconButton>
            </div>
          </div>
          <div class="text">
            <p class="t-label muted">Now playing</p>
            <h1 class="t-display-m">{track[0]}</h1>
            <p class="t-body-l muted">{track[1]}</p>
          </div>
        </header>

        <List>
          {#each TRACKS as [title, artist, name, length], i (title)}
            <ListItem
              {title}
              subtitle={artist}
              current={i === index}
              onclick={() => {
                index = i;
              }}
            >
              {#snippet leading()}<Thumbnail src={covers.find((c) => c.name === name)?.src} size={40} />{/snippet}
              {#snippet trailing()}<span class="t-small t-tabular muted">{length}</span>{/snippet}
            </ListItem>
          {/each}
        </List>

        <!-- glass above the content: the rows scroll under it -->
        <div class="bar t-glass" data-shadow="md">
          <Thumbnail src={cover?.src} size={40} />
          <div class="now">
            <p class="t-body-strong">{track[0]}</p>
            <p class="t-small muted">{track[1]}</p>
          </div>
          <IconButton
            label="Previous"
            variant="plain"
            onclick={() => {
              index = (index + TRACKS.length - 1) % TRACKS.length;
            }}
          >
            {#snippet icon()}<BlockIcon name="previous" />{/snippet}
          </IconButton>
          <IconButton label={playing ? 'Pause' : 'Play'} variant="accent" onclick={() => (playing = !playing)}>
            {#snippet icon()}<BlockIcon name={playing ? 'pause' : 'play'} />{/snippet}
          </IconButton>
          <IconButton
            label="Next"
            variant="plain"
            onclick={() => {
              index = (index + 1) % TRACKS.length;
            }}
          >
            {#snippet icon()}<BlockIcon name="next" />{/snippet}
          </IconButton>
          <div class="volume">
            <Slider label="Volume" bind:value={volume} />
          </div>
        </div>
      </div>
    </div>
  </Surface>
</AccentRegion>

<style>
  .layout {
    display: flex;
    align-items: flex-start;
    gap: var(--t-space-12);
    min-height: 100%;
  }
  /* the sidebar stays in view while the column scrolls */
  .layout > :global(.side) {
    position: sticky;
    top: 0;
    flex: none;
  }
  .fold {
    margin-top: auto;
    padding-top: var(--t-space-12);
  }
  /* the content column is at most 1200 wide */
  .column {
    flex: 1;
    max-width: 1200px;
    min-width: 0;
    padding: var(--t-space-24) var(--t-space-24) 0 var(--t-space-12);
  }
  .muted {
    color: var(--t-text-muted);
  }
  .hero {
    display: flex;
    align-items: flex-end;
    gap: var(--t-space-24);
    margin-bottom: var(--t-space-24);
  }
  .art {
    position: relative;
    flex: none;
    border-radius: var(--t-radius-lg);
    box-shadow: var(--t-shadow-lg);
  }
  .over {
    position: absolute;
    inset-block-end: var(--t-space-12);
    inset-inline-end: var(--t-space-12);
    display: flex;
    gap: var(--t-space-8);
  }
  .text {
    min-width: 0;
  }
  .text h1,
  .text p {
    margin: 0;
  }
  .text h1 {
    margin-block: var(--t-space-4) var(--t-space-8);
  }
  .bar {
    position: sticky;
    bottom: var(--t-space-12);
    display: flex;
    align-items: center;
    gap: var(--t-space-8);
    margin-top: var(--t-space-24);
    padding: var(--t-space-8) var(--t-space-16);
    border-radius: var(--t-radius-lg);
  }
  .now {
    flex: 1;
    min-width: 0;
  }
  .now p {
    margin: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .volume {
    width: 120px;
  }
</style>
