<!-- Don't: a badge is hidden from screen readers, so this button is just "Notifications" to them, with no hint that something is new (DESIGN.md, Badge). -->
<script lang="ts">
  import { Badge, IconButton } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

<IconButton label="Notifications">
  {#snippet icon()}<NavIcon name="bell" />{/snippet}
  {#snippet badge()}<Badge dot />{/snippet}
</IconButton>
