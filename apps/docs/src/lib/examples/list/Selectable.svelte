<script lang="ts">
  import { List, ListItem, Section } from '@tsuya/svelte';

  let sort = $state('name');
</script>

<div style="width: 100%">
  <List>
    <Section label="Sort by">
      <ListItem title="Name" selected={sort === 'name'} onclick={() => (sort = 'name')} />
      <ListItem title="Date added" selected={sort === 'date'} onclick={() => (sort = 'date')} />
      <ListItem title="Size" selected={sort === 'size'} onclick={() => (sort = 'size')} />
    </Section>
  </List>
</div>
