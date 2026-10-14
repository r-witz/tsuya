<script lang="ts">
  import { ListItem, Switch } from '@tsuya/svelte';

  let checked = $state(true);
</script>

<ListItem title="Notifications">
  {#snippet trailing()}<Switch bind:checked />{/snippet}
</ListItem>
