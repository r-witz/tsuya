<script lang="ts">
  import { Thumbnail } from '@tsuya/svelte';

  import { COVER } from '#lib/examples/art.ts';

  let { size = 'md' }: { size?: 'sm' | 'md' | 'lg' } = $props();
  const px = $derived({ sm: 40, md: 64, lg: 96 }[size]);
</script>

<Thumbnail src={COVER.ember} alt="Cover of Kind of Blue" size={px} />
