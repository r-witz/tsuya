<script lang="ts">
  import { IconButton } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';

  let { size = 'md' }: { size?: 'sm' | 'md' | 'lg' } = $props();
</script>

<IconButton label="Share" {size}>
  {#snippet icon()}<Icon name="share" />{/snippet}
</IconButton>
