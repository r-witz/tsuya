<script lang="ts">
  import { List, ListItem } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <List>
    <ListItem title="Buttons" subtitle="A link: it navigates" href="/components/button" />
    <ListItem title="Reset layout" subtitle="A button: it acts" onclick={() => {}} />
    <ListItem title="Version" subtitle="A plain row: it informs" />
  </List>
</div>
