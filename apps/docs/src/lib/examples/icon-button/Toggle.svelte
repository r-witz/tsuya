<script lang="ts">
  import { IconButton } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';

  let editing = $state(false);
</script>

<IconButton label="Edit" pressed={editing} onclick={() => (editing = !editing)}>
  {#snippet icon()}<Icon name="pencil" />{/snippet}
</IconButton>
