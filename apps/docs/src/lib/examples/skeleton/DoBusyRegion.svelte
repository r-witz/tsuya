<script lang="ts">
  import { Skeleton } from '@tsuya/svelte';
</script>

<div aria-busy="true" style="display: flex; gap: 12px; align-items: center; width: 100%">
  <Skeleton width={40} height={40} radius="full" />
  <Skeleton.Text lines={2} />
</div>
