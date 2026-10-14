<script lang="ts">
  import { Avatar, Badge } from '@tsuya/svelte';
</script>

<Avatar initials="AL" label="Ada Lovelace, online">
  {#snippet badge()}<Badge dot />{/snippet}
</Avatar>
<Avatar initials="GH" label="Grace Hopper, 3 unread messages">
  {#snippet badge()}<Badge count={3} />{/snippet}
</Avatar>
