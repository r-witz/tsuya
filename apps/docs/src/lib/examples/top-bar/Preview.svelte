<script lang="ts">
  import { IconButton, TopBar } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

<div class="art">
  <TopBar
    links={[
      { href: '/components/button', label: 'Button' },
      { href: '/components/top-bar', label: 'TopBar', current: true },
      { href: '/components/sidebar', label: 'Sidebar' },
    ]}
  >
    {#snippet start()}<strong>tsuya</strong>{/snippet}
    {#snippet end()}
      <IconButton label="Search" variant="plain">
        {#snippet icon()}<NavIcon name="search" />{/snippet}
      </IconButton>
    {/snippet}
  </TopBar>
</div>

<style>
  .art {
    display: flex;
    flex-direction: column;
    width: 100%;
    min-height: 168px;
    padding-bottom: var(--t-space-16);
    border-radius: var(--t-radius-md);
    background: linear-gradient(135deg, #1fb8a6, #0c2b3a);
  }
</style>
