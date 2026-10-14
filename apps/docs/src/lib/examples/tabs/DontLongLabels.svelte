<!-- Don't: tabs this long overflow the row, which then scrolls sideways (DESIGN.md, Tabs). -->
<script lang="ts">
  import { Tabs } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <Tabs.Root>
    <Tabs.List>
      <Tabs.Trigger value="all">Every message in every folder</Tabs.Trigger>
      <Tabs.Trigger value="unread">Messages I have not read yet</Tabs.Trigger>
      <Tabs.Trigger value="starred">Messages I starred for later</Tabs.Trigger>
    </Tabs.List>
    <Tabs.Content value="all">Every message.</Tabs.Content>
    <Tabs.Content value="unread">Unread messages.</Tabs.Content>
    <Tabs.Content value="starred">Starred messages.</Tabs.Content>
  </Tabs.Root>
</div>
