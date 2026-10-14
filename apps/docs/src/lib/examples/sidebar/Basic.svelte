<script lang="ts">
  import { Sidebar, SidebarGroup, SidebarItem } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

<Sidebar aria-label="Docs menu">
  <SidebarGroup label="Docs">
    <SidebarItem href="/components/sidebar" current>
      {#snippet icon()}<NavIcon name="folder" />{/snippet}
      Sidebar
    </SidebarItem>
    <SidebarItem href="/components/tab-bar" count={2}>
      {#snippet icon()}<NavIcon name="bell" />{/snippet}
      TabBar
    </SidebarItem>
  </SidebarGroup>
</Sidebar>
