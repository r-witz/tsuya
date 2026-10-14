<!-- Glass only above content (DESIGN.md, rule 3): the glass variant needs artwork under it, never a flat background. -->
<script lang="ts">
  import { Chip, ChipGroup } from '@tsuya/svelte';

  let filter = $state<string | string[]>('all');
</script>

<div class="art">
  <ChipGroup bind:value={filter} label="Show">
    <Chip value="all" glass>All</Chip>
    <Chip value="photos" glass>Photos</Chip>
    <Chip value="videos" glass>Videos</Chip>
  </ChipGroup>
</div>

<style>
  .art {
    display: flex;
    width: 100%;
    padding: var(--t-space-16);
    border-radius: var(--t-radius-md);
    background: linear-gradient(135deg, #1fb8a6, #0c2b3a);
  }
</style>
