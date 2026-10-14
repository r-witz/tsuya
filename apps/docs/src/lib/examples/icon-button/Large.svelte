<script lang="ts">
  import { IconButton } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<!-- A number from 40 to 72 sizes the large primary action; the icon is 38 % of it. -->
<IconButton label="Add" variant="accent" size={64}>
  {#snippet icon()}<Icon name="plus" />{/snippet}
</IconButton>
