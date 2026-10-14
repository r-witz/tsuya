<script lang="ts">
  import { Chip } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';

  let downloaded = $state(false);
</script>

<Chip selected={downloaded} onclick={() => (downloaded = !downloaded)}>
  {#snippet icon()}<Icon name="check" />{/snippet}
  Downloaded
</Chip>
