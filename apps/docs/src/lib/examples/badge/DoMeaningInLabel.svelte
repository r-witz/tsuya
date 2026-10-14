<script lang="ts">
  import { Badge, IconButton } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

<IconButton label="Notifications, 3 unread">
  {#snippet icon()}<NavIcon name="bell" />{/snippet}
  {#snippet badge()}<Badge count={3} />{/snippet}
</IconButton>
