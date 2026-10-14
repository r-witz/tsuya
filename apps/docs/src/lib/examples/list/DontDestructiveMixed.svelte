<!-- Don't: a destructive row stands alone in the last group (DESIGN.md, List, ListItem, Section). -->
<script lang="ts">
  import { List, ListItem, Section } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <List>
    <Section label="Account">
      <ListItem title="Profile" onclick={() => {}} />
      <ListItem title="Delete account" destructive onclick={() => {}} />
      <ListItem title="Privacy" onclick={() => {}} />
    </Section>
  </List>
</div>
