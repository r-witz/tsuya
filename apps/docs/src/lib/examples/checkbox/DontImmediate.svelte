<!-- Don't: a setting that applies at once is a Switch (DESIGN.md, Switch); a checkbox waits for a submit. -->
<script lang="ts">
  import { Checkbox, ListItem } from '@tsuya/svelte';

  let checked = $state(true);
</script>

<ListItem title="Notifications">
  {#snippet trailing()}<Checkbox bind:checked aria-label="Notifications" />{/snippet}
</ListItem>
