<!--
  Dashboard-lite: a page header, stats as rows (figures in tabular numbers, a hairline between them, no
  cards), and a list. Charts are for a later phase. No content leads and the numbers are not an image, so there is no
  accent and no ambient light: the neutral glow only. The change of a figure is told by its sign and an arrow, not by
  a status colour, which cannot sit on the glow.
-->
<script lang="ts">
  import { List, ListItem, PageHeader, Screen, SectionHeader, SegmentedControl } from '@tsuya/svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  const RANGES = {
    '7': { label: '7 days', stats: [18420, 2310, 1290, 62.4], change: [4.2, 1.1, -2.6, 0.8] },
    '30': { label: '30 days', stats: [84310, 6875, 5740, 59.9], change: [12.8, 3.4, 6.1, -1.3] },
    '90': { label: '90 days', stats: [241906, 14022, 16508, 61.2], change: [21.5, 9.7, 15.2, 2.4] },
  } as const;
  const LABELS = ['Plays', 'Listeners', 'Hours listened', 'Completion rate'];
  const TOP = [
    ['Low Sun', 'Nora Vale', 9120],
    ['Tidepool Letters', 'The Salt Choir', 7684],
    ['Violet Hour', 'Ines Marlow', 6402],
    ['Understory', 'Field Notes', 4975],
    ['First Light', 'Pale Harbour', 3318],
  ] as const;

  const count = new Intl.NumberFormat('en');
  const percent = new Intl.NumberFormat('en', { minimumFractionDigits: 1, maximumFractionDigits: 1 });

  let range = $state<string>('30');

  const current = $derived(RANGES[range as keyof typeof RANGES]);
  const stats = $derived(
    LABELS.map((label, i) => {
      const figure = current.stats[i] ?? 0;
      return {
        label,
        value: i === 3 ? `${percent.format(figure)} %` : count.format(figure),
        change: current.change[i] ?? 0,
      };
    }),
  );
</script>

<Screen>
  <div class="page">
    <PageHeader title="Overview" subtitle={`Last ${current.label} · updated 5 minutes ago`}>
      {#snippet actions()}
        <SegmentedControl
          label="Period"
          bind:value={range}
          options={Object.entries(RANGES).map(([value, { label }]) => ({ value, label }))}
        />
      {/snippet}
    </PageHeader>

    <dl class="stats">
      {#each stats as stat (stat.label)}
        <div class="stat">
          <dt class="t-small">{stat.label}</dt>
          <dd class="t-title-l t-tabular value">{stat.value}</dd>
          <dd class="t-small t-tabular change">
            <span class="arrow" class:down={stat.change < 0}><BlockIcon name="arrow-up" /></span>
            {stat.change < 0 ? '−' : '+'}{percent.format(Math.abs(stat.change))} %
            <span class="sr">versus the period before</span>
          </dd>
        </div>
      {/each}
    </dl>

    <SectionHeader title="Top tracks" count="5" />
    <List>
      {#each TOP as [title, artist, plays], i (title)}
        <ListItem {title} subtitle={artist}>
          {#snippet leading()}<span class="rank t-small t-tabular">{i + 1}</span>{/snippet}
          {#snippet trailing()}<span class="t-small t-tabular plays">{count.format(plays)} plays</span>{/snippet}
        </ListItem>
      {/each}
    </List>
  </div>
</Screen>

<style>
  .page {
    max-width: 1200px;
    margin-inline: auto;
    padding-top: var(--t-space-24);
  }
  /* stats as rows: two to a line on a phone, four on a wide page, a hairline above each */
  .stats {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
    gap: 0 var(--t-space-24);
    margin: var(--t-space-24) 0 0;
  }
  .stat {
    padding-block: var(--t-space-16);
    border-top: 1px solid var(--t-border);
  }
  .stat dt,
  .stat dd {
    margin: 0;
  }
  .stat dt,
  .change,
  .rank,
  .plays {
    color: var(--t-text-muted);
  }
  .value {
    margin-block: var(--t-space-4);
  }
  .change {
    display: flex;
    align-items: center;
    gap: var(--t-space-4);
  }
  .arrow {
    display: flex;
  }
  .arrow :global(svg) {
    width: var(--t-size-icon-sm);
    height: var(--t-size-icon-sm);
  }
  .arrow.down {
    rotate: 180deg;
  }
  .rank {
    min-width: var(--t-space-24);
    text-align: center;
  }
  .sr {
    position: absolute;
    width: 1px;
    height: 1px;
    overflow: hidden;
    clip-path: inset(100%);
  }
</style>
