<!-- A page header with actions, and section headers with a count and a "See all" action (DESIGN.md Patterns: Library). -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { IconButton, PageHeader, SectionHeader, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  interface Props {
    labels?: TsuyaLabels;
    onaction?: (name: string) => void;
    large?: boolean;
    maxWidth?: string;
  }

  let { labels = labelsEn, onaction = () => {}, large = false, maxWidth = '900px' }: Props = $props();
</script>

{#snippet shuffle()}
  <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true"><path d="M4 7h4l8 10h4M4 17h4l8-10h4" /></svg>
{/snippet}

<TsuyaProvider {labels}>
  <div style="max-width: {maxWidth}; margin: 0 auto; padding: var(--t-space-16)">
    <PageHeader title="Recently Added" subtitle="412 albums · 3 208 tracks" {large} data-testid="page-header">
      {#snippet actions()}
        <IconButton
          label="Shuffle"
          icon={shuffle}
          onclick={() => {
            onaction('shuffle');
          }}
        />
      {/snippet}
    </PageHeader>
    <SectionHeader
      title="Albums"
      count="24"
      action={{
        label: 'See all',
        onclick: () => {
          onaction('see-all');
        },
      }}
      data-testid="albums-header"
    />
    <SectionHeader title="Playlists" data-testid="playlists-header" />
  </div>
</TsuyaProvider>
