<!-- Glass only above content (DESIGN.md, rule 3): the glass variant needs artwork under it, never a flat background. -->
<script lang="ts">
  import { IconButton } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<div class="art">
  <IconButton label="Share" variant="glass">
    {#snippet icon()}<Icon name="share" />{/snippet}
  </IconButton>
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
