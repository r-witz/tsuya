<script lang="ts">
  import { Button } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';

  let { size = 'md' }: { size?: 'sm' | 'md' | 'lg' } = $props();
</script>

<Button variant="primary" {size}>
  {#snippet icon()}<Icon name="plus" />{/snippet}
  Create
</Button>
