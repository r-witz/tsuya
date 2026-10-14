<script lang="ts">
  import { accentFromColor } from '@tsuya/core';
  import { AccentRegion, List, ListItem, PageHeader, Screen } from '@tsuya/svelte';

  import { COVER } from '#lib/examples/art.ts';

  const pair = accentFromColor('#B06BD9');
</script>

<div class="phone">
  <AccentRegion {pair} style="display: contents">
    <Screen class="screen" ambient={COVER.violet}>
      <PageHeader title="Kind of Blue" subtitle="Miles Davis" />
      <List>
        <ListItem title="So What" subtitle="9:22" onclick={() => {}} />
        <ListItem title="Blue in Green" subtitle="5:37" onclick={() => {}} />
      </List>
    </Screen>
  </AccentRegion>
</div>

<style>
  .phone {
    position: relative;
    width: 360px;
    max-width: 100%;
    height: 520px;
    overflow: hidden;
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-lg);
  }
  .phone :global(.screen) {
    height: 100%;
    min-height: 0;
    overflow: auto;
  }
</style>
