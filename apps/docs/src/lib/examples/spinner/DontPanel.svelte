<!-- Don't: a whole panel of content that is on its way is a Skeleton, which keeps its shape; a spinner leaves a hole. -->
<script lang="ts">
  import { Spinner } from '@tsuya/svelte';
</script>

<div class="panel">
  <Spinner label="Loading the library" />
</div>

<style>
  .panel {
    display: grid;
    place-items: center;
    width: 100%;
    height: 8rem;
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
  }
</style>
