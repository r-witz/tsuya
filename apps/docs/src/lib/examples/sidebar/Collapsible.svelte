<script lang="ts">
  import { Button, Sidebar, SidebarGroup, SidebarItem } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';

  let collapsed = $state(true);
  let page = $state('library');
</script>

<div style="display: flex; gap: 16px; align-items: flex-start">
  <Sidebar aria-label="Collapsible" {collapsed}>
    <SidebarGroup label="Browse">
      <SidebarItem current={page === 'home'} onclick={() => (page = 'home')}>
        {#snippet icon()}<NavIcon name="home" />{/snippet}
        Home
      </SidebarItem>
      <SidebarItem current={page === 'library'} count={12} onclick={() => (page = 'library')}>
        {#snippet icon()}<NavIcon name="library" />{/snippet}
        Library
      </SidebarItem>
    </SidebarGroup>
    <SidebarGroup label="You">
      <SidebarItem current={page === 'settings'} onclick={() => (page = 'settings')}>
        {#snippet icon()}<NavIcon name="settings" />{/snippet}
        Settings
      </SidebarItem>
    </SidebarGroup>
  </Sidebar>
  <Button variant="secondary" onclick={() => (collapsed = !collapsed)}>
    {collapsed ? 'Expand' : 'Collapse'}
  </Button>
</div>
