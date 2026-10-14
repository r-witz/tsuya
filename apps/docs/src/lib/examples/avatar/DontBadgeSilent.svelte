<!-- Don't: a badge is decorative, so its meaning must be in the label (DESIGN.md, Badge: "its meaning is part of the host's label"). -->
<script lang="ts">
  import { Avatar, Badge } from '@tsuya/svelte';
</script>

<Avatar initials="AL" label="Ada Lovelace">
  {#snippet badge()}<Badge dot />{/snippet}
</Avatar>
