<script lang="ts">
  import { Avatar, Badge } from '@tsuya/svelte';
</script>

<Avatar initials="AL" label="Ada Lovelace, online">
  {#snippet badge()}<Badge dot />{/snippet}
</Avatar>
