<!-- Don't: an icon that does not say what it does; give that action a Button with its label. -->
<script lang="ts">
  import { IconButton } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<IconButton label="Upload to the archive" variant="plain">
  {#snippet icon()}<Icon name="upload" />{/snippet}
</IconButton>
