<!--
  Library and grid: a page header with counts, chips (sort, filters), a grid and list segmented control, and
  the three states that are not "some albums": loading (skeletons at the final size), empty and no result. No item
  leads in a grid, so the page has the neutral accent; each item keeps the region of its own cover, and the ambient
  background follows the item that is hovered or focused. The "State shown" control is only here to show the states.
-->
<script lang="ts">
  import type { ImageAccent } from '@tsuya/core';
  import {
    AccentRegion,
    Button,
    Chip,
    ChipGroup,
    List,
    ListItem,
    PageHeader,
    Screen,
    SearchInput,
    SegmentedControl,
    Skeleton,
    Thumbnail,
  } from '@tsuya/svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  interface Cover {
    name: string;
    src: string;
    pair: ImageAccent;
  }

  let { covers }: { covers: Cover[] } = $props();

  // title, artist, year, cover, tracks, favourite, downloaded: the order is the order they were added in
  const DATA = [
    ['Slow Burn', 'Nora Vale', 2024, 'Ember', 6, true, true],
    ['Tidepool Letters', 'The Salt Choir', 2022, 'Reef', 11, false, true],
    ['Violet Hour', 'Ines Marlow', 2025, 'Dusk', 9, true, false],
    ['Understory', 'Field Notes', 2021, 'Moss', 14, false, false],
    ['Grey Weather', 'Pale Harbour', 2023, 'Slate', 8, false, true],
    ['First Light', 'Ines Marlow', 2020, 'Dawn', 10, true, false],
    ['Cinders', 'Nora Vale', 2019, 'Ember', 12, false, false],
    ['Low Tide', 'The Salt Choir', 2025, 'Reef', 7, false, true],
  ] as const;

  const albums = $derived(
    DATA.map(([title, artist, year, name, tracks, favourite, downloaded]) => ({
      title,
      artist,
      year,
      tracks,
      favourite,
      downloaded,
      cover: covers.find((c) => c.name === name),
    })),
  );

  let demo = $state('albums'); // what the library holds: albums, nothing yet, or still loading
  let view = $state('grid');
  let sort = $state('recent');
  let filters = $state<string[]>([]);
  let query = $state('');
  let lit = $state(0); // the item that lights the ambient background: the first, until another is hovered or focused

  const loading = $derived(demo === 'loading');
  const all = $derived(demo === 'albums' ? albums : []);
  const shown = $derived.by(() => {
    const found = all
      .filter((a) => !filters.includes('favourites') || a.favourite)
      .filter((a) => !filters.includes('downloaded') || a.downloaded)
      .filter((a) => `${a.title} ${a.artist}`.toLowerCase().includes(query.trim().toLowerCase()));
    if (sort === 'title') return found.toSorted((a, b) => a.title.localeCompare(b.title));
    if (sort === 'artist') return found.toSorted((a, b) => a.artist.localeCompare(b.artist));
    return found.toReversed();
  });
  const tracks = $derived(all.reduce((sum, a) => sum + a.tracks, 0));
  const leading = $derived(shown[lit] ?? shown[0]);

  function clear() {
    query = '';
    filters = [];
  }
</script>

{#snippet gridIcon()}<BlockIcon name="grid" />{/snippet}
{#snippet listIcon()}<BlockIcon name="list" />{/snippet}

<Screen ambient={leading?.cover?.src} ambientOpacity={leading?.cover?.pair.ambient}>
  <div class="page" aria-busy={loading}>
    <div>
      <SegmentedControl
        label="State shown"
        bind:value={demo}
        options={[
          { value: 'albums', label: 'Albums' },
          { value: 'loading', label: 'Loading' },
          { value: 'empty', label: 'Empty' },
        ]}
      />
    </div>
    <PageHeader
      title="Library"
      subtitle={loading ? 'Loading' : `${String(all.length)} albums · ${String(tracks)} tracks`}
    >
      {#snippet actions()}
        <SegmentedControl
          label="View"
          bind:value={view}
          options={[
            { value: 'grid', label: 'Grid', icon: gridIcon },
            { value: 'list', label: 'List', icon: listIcon },
          ]}
        />
      {/snippet}
    </PageHeader>

    <div class="tools">
      <div class="search"><SearchInput label="Search albums" bind:value={query} /></div>
      <ChipGroup label="Sort by" bind:value={sort}>
        <Chip value="recent">Recent</Chip>
        <Chip value="title">Title</Chip>
        <Chip value="artist">Artist</Chip>
      </ChipGroup>
      <ChipGroup label="Filters" multiple bind:value={filters}>
        <Chip value="favourites">Favourites</Chip>
        <Chip value="downloaded">Downloaded</Chip>
      </ChipGroup>
    </div>
    <p class="sr" role="status">{loading ? '' : `${String(shown.length)} albums`}</p>

    {#if loading}
      <div class="grid">
        {#each { length: 8 }, i (i)}
          <div class="skeleton">
            <Skeleton width={148} height={148} radius="md" />
            <Skeleton width="80%" height={16} />
            <Skeleton width="55%" height={12} />
          </div>
        {/each}
      </div>
    {:else if all.length === 0}
      <div class="state">
        <h2 class="t-title-m">Your library is empty</h2>
        <p class="t-body">Add an album and it will show up here.</p>
        <Button variant="primary" onclick={() => (demo = 'albums')}>Add albums</Button>
      </div>
    {:else if shown.length === 0}
      <div class="state">
        <h2 class="t-title-m">No album matches</h2>
        <p class="t-body">Try another word, or remove a filter.</p>
        <Button variant="secondary" onclick={clear}>Clear search and filters</Button>
      </div>
    {:else if view === 'grid'}
      <ul class="grid">
        {#each shown as album, i (album.title)}
          <li>
            <AccentRegion pair={album.cover?.pair ?? null}>
              <button
                type="button"
                class="item t-pressable"
                data-press="none"
                data-lit={lit === i ? '' : undefined}
                onpointerenter={() => (lit = i)}
                onfocus={() => (lit = i)}
              >
                <span class="art"><Thumbnail src={album.cover?.src} size={148} /></span>
                <span class="t-body-strong line">{album.title}</span>
                <span class="t-small line muted">{album.artist}</span>
              </button>
            </AccentRegion>
          </li>
        {/each}
      </ul>
    {:else}
      <List>
        {#each shown as album, i (album.title)}
          <ListItem
            title={album.title}
            subtitle={`${album.artist} · ${String(album.year)}`}
            onclick={() => (lit = i)}
            onpointerenter={() => (lit = i)}
          >
            {#snippet leading()}<Thumbnail src={album.cover?.src} size={48} />{/snippet}
            {#snippet trailing()}<span class="t-small t-tabular muted">{album.tracks} tracks</span>{/snippet}
          </ListItem>
        {/each}
      </List>
    {/if}
  </div>
</Screen>

<style>
  .page {
    display: flex;
    flex-direction: column;
    gap: var(--t-space-16);
    max-width: 1200px;
    margin-inline: auto;
    padding-top: var(--t-space-24);
  }
  .tools {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: var(--t-space-12);
  }
  .search {
    flex: 1 1 220px;
  }
  .muted {
    color: var(--t-text-muted);
  }
  /* columns at least 148 wide, gaps 16 across and 24 down */
  .grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, 148px);
    justify-content: space-between;
    gap: var(--t-space-24) var(--t-space-16);
    margin: 0;
    padding: 0;
    list-style: none;
  }
  .skeleton {
    display: flex;
    flex-direction: column;
    gap: var(--t-space-8);
  }
  .item {
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
  /* the lit item has a ring like a focus ring, in its own accent */
  .art {
    display: flex;
    margin-bottom: var(--t-space-4);
    border-radius: var(--t-radius-md);
  }
  .item[data-lit] .art {
    outline: var(--t-state-focus-width) solid var(--t-accent);
    outline-offset: var(--t-state-focus-offset);
  }
  .line {
    max-width: 100%;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  /* an empty state: a short title, one sentence, one action */
  .state {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--t-space-12);
    padding: var(--t-space-48) var(--t-space-16);
    text-align: center;
  }
  .state h2,
  .state p {
    margin: 0;
  }
  .state p {
    color: var(--t-text-muted);
  }
  .sr {
    position: absolute;
    width: 1px;
    height: 1px;
    overflow: hidden;
    clip-path: inset(100%);
  }
</style>
