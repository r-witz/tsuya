<script lang="ts">
  import { Avatar, List, ListItem, Section } from '@tsuya/svelte';
</script>

<div style="width: min(100%, 420px)">
  <List>
    <ListItem title="Ada Lovelace" subtitle="ada@example.com" tall href="/components/avatar">
      {#snippet leading()}<Avatar initials="AL" colors={['#1F7A6E', '#0C2B3A']} />{/snippet}
    </ListItem>
    <Section label="General">
      <ListItem title="Language" onclick={() => {}}>
        {#snippet trailing()}<span>English</span>{/snippet}
      </ListItem>
      <ListItem title="Notifications" subtitle="Alerts and sounds" onclick={() => {}} />
    </Section>
    <Section label="Account">
      <ListItem title="Sign out" destructive onclick={() => {}} />
    </Section>
  </List>
</div>
