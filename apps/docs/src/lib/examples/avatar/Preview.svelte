<script lang="ts">
  import { Avatar } from '@tsuya/svelte';

  let { size = 'md' }: { size?: 'sm' | 'md' | 'lg' } = $props();
  const px = $derived({ sm: 32, md: 40, lg: 56 }[size]);
</script>

<Avatar initials="AL" colors={['#1F7A6E', '#0C2B3A']} label="Ada Lovelace" size={px} />
