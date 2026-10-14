<script lang="ts">
  import { Spinner } from '@tsuya/svelte';

  let { size = 'md' }: { size?: 'sm' | 'md' | 'lg' } = $props();
</script>

<Spinner {size} />
