<script lang="ts">
  import { List, ListItem, PageHeader, Screen, SectionHeader, TabBar } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';

  let value = $state('library');
</script>

{#snippet home()}<NavIcon name="home" />{/snippet}
{#snippet library()}<NavIcon name="library" />{/snippet}
{#snippet inbox()}<NavIcon name="inbox" />{/snippet}
{#snippet user()}<NavIcon name="user" />{/snippet}

<div class="phone">
  <Screen class="screen">
    <PageHeader title="Library" subtitle="412 albums" />
    <SectionHeader title="Recently added" />
    <List>
      <ListItem title="Kind of Blue" subtitle="Miles Davis" onclick={() => {}} />
      <ListItem title="A Love Supreme" subtitle="John Coltrane" onclick={() => {}} />
      <ListItem title="Mingus Ah Um" subtitle="Charles Mingus" onclick={() => {}} />
      <ListItem title="Time Out" subtitle="The Dave Brubeck Quartet" onclick={() => {}} />
      <ListItem title="Blue Train" subtitle="John Coltrane" onclick={() => {}} />
      <ListItem title="Saxophone Colossus" subtitle="Sonny Rollins" onclick={() => {}} />
    </List>
    {#snippet dock()}
      <TabBar
        bind:value
        items={[
          { value: 'home', label: 'Home', icon: home },
          { value: 'library', label: 'Library', icon: library },
          { value: 'inbox', label: 'Inbox', icon: inbox, badge: { count: 3, label: '3 new' } },
          { value: 'profile', label: 'Profile', icon: user },
        ]}
      />
    {/snippet}
  </Screen>
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
