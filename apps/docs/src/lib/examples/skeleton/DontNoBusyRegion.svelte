<!-- Don't: the blocks are hidden from screen readers and nothing says that the region is busy (DESIGN.md, Skeleton). -->
<script lang="ts">
  import { Skeleton } from '@tsuya/svelte';
</script>

<div style="display: flex; gap: 12px; align-items: center; width: 100%">
  <Skeleton width={40} height={40} radius="full" />
  <Skeleton.Text lines={2} />
</div>
