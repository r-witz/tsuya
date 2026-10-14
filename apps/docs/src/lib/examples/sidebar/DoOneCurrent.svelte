<script lang="ts">
  import { Sidebar, SidebarItem } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

<Sidebar aria-label="One current">
  <SidebarItem current>
    {#snippet icon()}<NavIcon name="home" />{/snippet}
    Home
  </SidebarItem>
  <SidebarItem>
    {#snippet icon()}<NavIcon name="library" />{/snippet}
    Library
  </SidebarItem>
</Sidebar>
