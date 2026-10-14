<script lang="ts">
  import { Chip, ChipGroup } from '@tsuya/svelte';

  let genres = $state<string | string[]>(['jazz']);
</script>

<ChipGroup bind:value={genres} label="Genres" multiple>
  <Chip value="jazz">Jazz</Chip>
  <Chip value="rock">Rock</Chip>
  <Chip value="folk">Folk</Chip>
  <Chip value="soul">Soul</Chip>
</ChipGroup>
