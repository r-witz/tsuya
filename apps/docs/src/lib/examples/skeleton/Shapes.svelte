<script lang="ts">
  import { Skeleton } from '@tsuya/svelte';
</script>

<div aria-busy="true" style="display: flex; gap: 12px; align-items: center">
  <Skeleton width={48} height={48} radius="full" />
  <Skeleton width={96} height={64} radius="md" />
  <Skeleton width={160} height={16} />
</div>
