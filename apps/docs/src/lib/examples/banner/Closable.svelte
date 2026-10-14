<script lang="ts">
  import { Banner, Button } from '@tsuya/svelte';

  let visible = $state(true);
</script>

<div style="display: grid; gap: 12px; width: 100%">
  {#if visible}
    <Banner tone="info" title="Tip" onclose={() => (visible = false)}>
      Press F6 to reach a toast from the keyboard.
    </Banner>
  {:else}
    <div><Button variant="secondary" onclick={() => (visible = true)}>Show the banner again</Button></div>
  {/if}
</div>
