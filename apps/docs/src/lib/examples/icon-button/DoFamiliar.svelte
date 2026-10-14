<script lang="ts">
  import { IconButton } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<IconButton label="Delete" variant="plain">
  {#snippet icon()}<Icon name="trash" />{/snippet}
</IconButton>
<IconButton label="Share" variant="plain">
  {#snippet icon()}<Icon name="share" />{/snippet}
</IconButton>
