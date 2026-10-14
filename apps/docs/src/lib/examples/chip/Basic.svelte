<script lang="ts">
  import { Chip, ChipGroup } from '@tsuya/svelte';

  let sort = $state<string | string[]>('recent');
</script>

<ChipGroup bind:value={sort} label="Sort by">
  <Chip value="recent">Recent</Chip>
  <Chip value="title">Title</Chip>
  <Chip value="artist">Artist</Chip>
  <Chip value="year">Year</Chip>
</ChipGroup>
