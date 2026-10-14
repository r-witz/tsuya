<!--
  Empty, error and offline states: each is a short title, one sentence and one action, written
  to say what is missing or what to do next, never a code. A state that lasts (offline) is a banner above the content
  that is still usable; one that replaces the content (empty, error) is centred in its place. The "State shown"
  control is only here to move between them; "Try again" and "Retry" really retry, and always succeed the second time.
-->
<script lang="ts">
  import { Banner, Button, List, ListItem, PageHeader, Screen, SegmentedControl, toast } from '@tsuya/svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  const DOWNLOADS = [
    ['Slow Burn', 'Nora Vale', '84 MB'],
    ['Tidepool Letters', 'The Salt Choir', '132 MB'],
    ['Violet Hour', 'Ines Marlow', '97 MB'],
  ] as const;

  let shown = $state('empty'); // online, empty, error or offline
  let retrying = $state(false);

  function retry() {
    retrying = true;
    const wasOffline = shown === 'offline';
    setTimeout(() => {
      retrying = false;
      shown = 'online';
      if (wasOffline) toast('Back online', { icon: 'check' });
    }, 900);
  }
</script>

<Screen>
  <div class="page">
    <div>
      <SegmentedControl
        label="State shown"
        bind:value={shown}
        options={[
          { value: 'online', label: 'Online' },
          { value: 'empty', label: 'Empty' },
          { value: 'error', label: 'Error' },
          { value: 'offline', label: 'Offline' },
        ]}
      />
    </div>

    <PageHeader
      title="Downloads"
      subtitle={shown === 'online' || shown === 'offline' ? '3 albums · 313 MB' : undefined}
    />

    {#if shown === 'offline'}
      <!-- a lasting state: a banner above the content, which stays usable -->
      <Banner tone="warning" title="You are offline">
        Your downloads still play. New albums and changes wait until you are back online.
        {#snippet actions()}
          <Button size="sm" variant="secondary" loading={retrying} onclick={retry}>Retry</Button>
        {/snippet}
      </Banner>
    {/if}

    {#if shown === 'empty'}
      <section class="state" aria-labelledby="empty-title">
        <span class="mark"><BlockIcon name="download" /></span>
        <h2 id="empty-title" class="t-title-m">No downloads yet</h2>
        <p class="t-body">Download an album and it plays without a connection.</p>
        <Button variant="primary" onclick={() => (shown = 'online')}>Browse albums</Button>
      </section>
    {:else if shown === 'error'}
      <!-- an alert: it replaces what the person was waiting for, so it is read out when it appears -->
      <section class="state" role="alert">
        <span class="mark"><BlockIcon name="wifi-off" /></span>
        <h2 class="t-title-m">We could not load your downloads</h2>
        <p class="t-body">Check your connection, then try again.</p>
        <Button variant="primary" loading={retrying} onclick={retry}>Try again</Button>
      </section>
    {:else}
      <List>
        {#each DOWNLOADS as [title, artist, size] (title)}
          <ListItem {title} subtitle={artist}>
            {#snippet trailing()}<span class="size t-small t-tabular">{size}</span>{/snippet}
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
    max-width: 720px;
    margin-inline: auto;
    padding-top: var(--t-space-24);
  }
  /* centred, in the place of the content: a short title, one sentence, one action */
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
    max-width: 40ch;
    margin-bottom: var(--t-space-4);
    color: var(--t-text-muted);
  }
  .mark {
    display: grid;
    place-items: center;
    width: var(--t-size-control-lg);
    height: var(--t-size-control-lg);
    border-radius: var(--t-radius-full);
    background: var(--t-fill-strong);
    color: var(--t-text-muted);
  }
  .mark :global(svg) {
    width: var(--t-size-icon);
    height: var(--t-size-icon);
  }
  .size {
    color: var(--t-text-muted);
  }
</style>
