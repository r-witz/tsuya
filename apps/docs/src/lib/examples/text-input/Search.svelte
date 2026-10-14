<script lang="ts">
  import { SearchInput } from '@tsuya/svelte';

  let query = $state('');
</script>

<div class="art">
  <SearchInput bind:value={query} label="Search photos" placeholder="Search" size="sm" glass />
</div>

<style>
  .art {
    display: flex;
    width: 100%;
    padding: var(--t-space-16);
    border-radius: var(--t-radius-md);
    background: linear-gradient(135deg, #1fb8a6, #0c2b3a);
  }
  .art :global(.t-search) {
    flex: 1;
  }
</style>
