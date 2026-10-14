<script lang="ts">
  import { IconButton, ScreenBar } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<div style="width: 100%">
  <ScreenBar title="Albums" onBack={() => {}} backLabel="Back">
    {#snippet action()}
      <IconButton label="Share" variant="plain">
        {#snippet icon()}<Icon name="share" />{/snippet}
      </IconButton>
    {/snippet}
  </ScreenBar>
</div>
