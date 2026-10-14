<!-- The sidebar of a library app: the current page, two groups, a count and an action. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Sidebar, SidebarGroup, SidebarItem, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    collapsed?: boolean;
    /** The label of the albums item. */
    albums?: string;
    onnew?: () => void;
  }

  let { collapsed = false, albums = 'Albums', onnew = () => {} }: Props = $props();
</script>

{#snippet star()}<svg viewBox="0 0 24 24"><path d="M12 3l3 6 6 1-4 4 1 6-6-3-6 3 1-6-4-4 6-1z" /></svg>{/snippet}

<TsuyaProvider labels={labelsEn}>
  <Sidebar {collapsed} aria-label="Library" data-testid="sidebar">
    <SidebarItem href="#home" icon={star} current>Home</SidebarItem>
    <SidebarGroup label="Library">
      <SidebarItem href="#albums" icon={star} count={12}>{albums}</SidebarItem>
      <SidebarItem href="#artists" icon={star}>Artists</SidebarItem>
    </SidebarGroup>
    <SidebarGroup label="Playlists">
      <SidebarItem icon={star} onclick={onnew}>New playlist</SidebarItem>
    </SidebarGroup>
  </Sidebar>
</TsuyaProvider>
