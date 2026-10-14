<!-- Don't: a switch is never behind a Save step (DESIGN.md, Switch: "applies at once, with no save step"). -->
<script lang="ts">
  import { Button, ListItem, Switch } from '@tsuya/svelte';

  let checked = $state(true);
</script>

<ListItem title="Notifications">
  {#snippet trailing()}<Switch bind:checked />{/snippet}
</ListItem>
<Button variant="primary">Save</Button>
