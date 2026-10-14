<!-- Glass only above content (DESIGN.md, rule 3): the glass variant needs artwork under it, never a flat background. -->
<script lang="ts">
  import { Button } from '@tsuya/svelte';
</script>

<div class="art">
  <Button variant="glass">Share</Button>
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
