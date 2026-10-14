<!-- Don't: the current item is the page that is shown, and only one page is (DESIGN.md, Sidebar). -->
<script lang="ts">
  import { Sidebar, SidebarItem } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

<Sidebar aria-label="Many current">
  <SidebarItem current>
    {#snippet icon()}<NavIcon name="home" />{/snippet}
    Home
  </SidebarItem>
  <SidebarItem current>
    {#snippet icon()}<NavIcon name="library" />{/snippet}
    Library
  </SidebarItem>
</Sidebar>
