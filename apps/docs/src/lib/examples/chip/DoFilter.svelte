<script lang="ts">
  import { Chip, ChipGroup } from '@tsuya/svelte';

  let kinds = $state<string | string[]>(['unread']);
</script>

<ChipGroup bind:value={kinds} label="Filter" multiple>
  <Chip value="unread">Unread</Chip>
  <Chip value="starred">Starred</Chip>
  <Chip value="mine">Assigned to me</Chip>
</ChipGroup>
