<script lang="ts">
  import { IconButton } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<IconButton label="Edit" variant="filled">
  {#snippet icon()}<Icon name="pencil" />{/snippet}
</IconButton>
<IconButton label="Share" variant="plain">
  {#snippet icon()}<Icon name="share" />{/snippet}
</IconButton>
<IconButton label="Add" variant="accent">
  {#snippet icon()}<Icon name="plus" />{/snippet}
</IconButton>
