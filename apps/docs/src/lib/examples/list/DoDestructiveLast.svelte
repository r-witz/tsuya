<script lang="ts">
  import { List, ListItem, Section } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <List>
    <Section label="Account">
      <ListItem title="Profile" onclick={() => {}} />
      <ListItem title="Privacy" onclick={() => {}} />
    </Section>
    <Section label="Session">
      <ListItem title="Delete account" destructive onclick={() => {}} />
    </Section>
  </List>
</div>
