<script lang="ts">
  import { TabBar } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

{#snippet home()}<NavIcon name="home" />{/snippet}
{#snippet library()}<NavIcon name="library" />{/snippet}
{#snippet inbox()}<NavIcon name="inbox" />{/snippet}
{#snippet user()}<NavIcon name="user" />{/snippet}

<div class="art">
  <TabBar
    style="width: 100%"
    items={[
      { value: 'home', label: 'Home', icon: home },
      { value: 'library', label: 'Library', icon: library },
      { value: 'inbox', label: 'Inbox', icon: inbox, badge: { count: 3, label: '3 new' } },
      { value: 'profile', label: 'Profile', icon: user },
    ]}
  />
</div>

<style>
  .art {
    display: flex;
    align-items: flex-end;
    width: 100%;
    min-height: 140px;
    padding: var(--t-space-12);
    border-radius: var(--t-radius-md);
    background: linear-gradient(135deg, #1fb8a6, #0c2b3a);
  }
</style>
