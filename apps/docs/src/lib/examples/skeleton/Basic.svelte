<script lang="ts">
  import { Skeleton } from '@tsuya/svelte';
</script>

<div aria-busy="true" style="display: grid; gap: 12px; width: 100%">
  <Skeleton height={20} width="40%" />
  <Skeleton.Text />
</div>
