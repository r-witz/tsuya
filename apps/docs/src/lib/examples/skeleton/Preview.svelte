<script lang="ts">
  import { Skeleton } from '@tsuya/svelte';
</script>

<div aria-busy="true" style="display: grid; gap: 12px; width: 280px">
  <Skeleton width={48} height={48} radius="full" />
  <Skeleton.Text lines={3} />
</div>
