<!--
  Phone shell: Screen, 20 of margin on each side, a floating glass tab bar in its dock, and a sheet
  rising from the bottom. The "player" is the showcase of the material: what leads the screen (the cover) gives it
  its accent and its light (AccentRegion, Screen's ambient), and the controls over the artwork are control glass.
  On the Library and Search tabs no item leads, so there is no accent and no ambient: only the glow.
-->
<script lang="ts">
  import type { ImageAccent } from '@tsuya/core';
  import {
    AccentRegion,
    IconButton,
    List,
    ListItem,
    PageHeader,
    Screen,
    ScreenBar,
    SearchInput,
    Sheet,
    Slider,
    TabBar,
    Thumbnail,
    type TabBarItem,
  } from '@tsuya/svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  interface Cover {
    name: string;
    src: string;
    pair: ImageAccent;
  }

  let { covers }: { covers: Cover[] } = $props();

  // title, artist, cover, length in seconds
  const TRACKS = [
    ['Low Sun', 'Nora Vale', 'Ember', 222],
    ['Tidepool Letters', 'The Salt Choir', 'Reef', 248],
    ['Violet Hour', 'Ines Marlow', 'Dusk', 201],
    ['Understory', 'Field Notes', 'Moss', 263],
  ] as const;
  const TABS: TabBarItem[] = [
    { value: 'library', label: 'Library', icon: library },
    { value: 'search', label: 'Search', icon: search },
    { value: 'player', label: 'Playing', icon: play },
  ];

  let tab = $state('player');
  let index = $state(0);
  let playing = $state(false);
  let position = $state(72);
  let liked = $state(false);
  let shuffle = $state(false);
  let repeat = $state(false);
  let query = $state('');
  let queue = $state(false);

  const track = $derived(TRACKS[index] ?? TRACKS[0]);
  const cover = $derived(covers.find((c) => c.name === track[2]));
  // the cover leads on the player alone
  const leads = $derived(tab === 'player');
  const ALL = TRACKS.map((t, i) => ({ t, i }));
  const found = $derived(ALL.filter(({ t }) => `${t[0]} ${t[1]}`.toLowerCase().includes(query.toLowerCase())));

  const clock = (seconds: number) => `${String(Math.floor(seconds / 60))}:${String(seconds % 60).padStart(2, '0')}`;

  function pick(i: number) {
    index = i;
    position = 0;
    tab = 'player';
    queue = false;
  }

  // the position moves on while it plays: that motion is the information
  $effect(() => {
    if (!playing) return;
    const timer = setInterval(() => {
      if (position + 1 >= track[3]) pick((index + 1) % TRACKS.length);
      else position += 1;
    }, 1000);
    return () => {
      clearInterval(timer);
    };
  });
</script>

{#snippet library()}<BlockIcon name="library" />{/snippet}
{#snippet search()}<BlockIcon name="search" />{/snippet}
{#snippet play()}<BlockIcon name="play" />{/snippet}
{#snippet dock()}<TabBar bind:value={tab} items={TABS} aria-label="Sections" />{/snippet}
{#snippet rows(items: { t: (typeof TRACKS)[number]; i: number }[])}
  <List>
    {#each items as { t, i } (t[0])}
      <ListItem
        title={t[0]}
        subtitle={t[1]}
        current={i === index}
        onclick={() => {
          pick(i);
        }}
      >
        {#snippet leading()}<Thumbnail src={covers.find((c) => c.name === t[2])?.src} size={48} />{/snippet}
        {#snippet trailing()}<span class="t-small t-tabular muted">{clock(t[3])}</span>{/snippet}
      </ListItem>
    {/each}
  </List>
{/snippet}

<AccentRegion pair={leads ? (cover?.pair ?? null) : null} style="display: contents">
  <Screen ambient={leads ? cover?.src : null} ambientOpacity={cover?.pair.ambient} {dock}>
    {#if tab === 'library'}
      <PageHeader title="Library" subtitle="4 tracks" />
      <!-- eslint-disable-next-line @typescript-eslint/no-confusing-void-expression -- the parser types a local snippet as void -->
      {@render rows(ALL)}
    {:else if tab === 'search'}
      <PageHeader title="Search" />
      <div class="field"><SearchInput label="Search tracks" bind:value={query} /></div>
      <!-- eslint-disable-next-line @typescript-eslint/no-confusing-void-expression -- the parser types a local snippet as void -->
      {@render rows(found)}
    {:else}
      <div class="player">
        <ScreenBar
          title="Now playing"
          subtitle={track[1]}
          onBack={() => (tab = 'library')}
          backLabel="Back to the library"
        >
          {#snippet action()}
            <IconButton label="Up next" onclick={() => (queue = true)}>
              {#snippet icon()}<BlockIcon name="list" />{/snippet}
            </IconButton>
          {/snippet}
        </ScreenBar>

        <div class="art">
          <Thumbnail src={cover?.src} alt={`${track[0]}, cover`} size={300} />
          <!-- control glass: a veil over mid-to-dark artwork, never over a very light picture -->
          <div class="over">
            <IconButton label="Like" variant="glass" pressed={liked} onclick={() => (liked = !liked)}>
              {#snippet icon()}<BlockIcon name="heart" />{/snippet}
            </IconButton>
            <IconButton label="Share" variant="glass">
              {#snippet icon()}<BlockIcon name="share" />{/snippet}
            </IconButton>
          </div>
        </div>

        <div class="titles">
          <h1 class="t-title-l">{track[0]}</h1>
          <p class="t-body muted">{track[1]}</p>
        </div>

        <Slider label="Position" min={0} max={track[3]} step={1} bind:value={position} valueLabel={clock} />
        <div class="times t-small t-tabular muted">
          <span>{clock(position)}</span><span>-{clock(track[3] - position)}</span>
        </div>

        <div class="transport">
          <IconButton label="Shuffle" variant="plain" pressed={shuffle} onclick={() => (shuffle = !shuffle)}>
            {#snippet icon()}<BlockIcon name="shuffle" />{/snippet}
          </IconButton>
          <IconButton
            label="Previous"
            variant="plain"
            onclick={() => {
              pick((index + TRACKS.length - 1) % TRACKS.length);
            }}
          >
            {#snippet icon()}<BlockIcon name="previous" />{/snippet}
          </IconButton>
          <!-- the one accent action of the screen -->
          <IconButton
            label={playing ? 'Pause' : 'Play'}
            variant="accent"
            size={72}
            onclick={() => (playing = !playing)}
          >
            {#snippet icon()}<BlockIcon name={playing ? 'pause' : 'play'} />{/snippet}
          </IconButton>
          <IconButton
            label="Next"
            variant="plain"
            onclick={() => {
              pick((index + 1) % TRACKS.length);
            }}
          >
            {#snippet icon()}<BlockIcon name="next" />{/snippet}
          </IconButton>
          <IconButton label="Repeat" variant="plain" pressed={repeat} onclick={() => (repeat = !repeat)}>
            {#snippet icon()}<BlockIcon name="repeat" />{/snippet}
          </IconButton>
        </div>
      </div>
    {/if}
  </Screen>
</AccentRegion>

<!-- a sheet rises from the bottom -->
<Sheet.Root bind:open={queue}>
  <Sheet.Content>
    <Sheet.Title>Up next</Sheet.Title>
    <!-- eslint-disable-next-line @typescript-eslint/no-confusing-void-expression -- the parser types a local snippet as void -->
    {@render rows(ALL)}
  </Sheet.Content>
</Sheet.Root>

<style>
  .muted {
    color: var(--t-text-muted);
  }
  .field {
    margin-block: var(--t-space-16);
  }
  .player {
    display: flex;
    flex-direction: column;
    gap: var(--t-space-16);
    max-width: 420px;
    margin-inline: auto;
    padding-top: var(--t-space-12);
  }
  .art {
    position: relative;
    align-self: center;
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
  .titles h1,
  .titles p {
    margin: 0;
  }
  .times {
    display: flex;
    justify-content: space-between;
    margin-top: calc(var(--t-space-8) * -1);
  }
  .transport {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
</style>
