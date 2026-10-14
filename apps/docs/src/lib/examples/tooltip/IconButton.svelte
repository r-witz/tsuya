<script lang="ts">
  import { IconButton } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<!-- An IconButton shows its label as a tooltip by itself; tooltip={false} turns it off. -->
<IconButton label="Share" variant="plain">
  {#snippet icon()}<Icon name="share" />{/snippet}
</IconButton>
