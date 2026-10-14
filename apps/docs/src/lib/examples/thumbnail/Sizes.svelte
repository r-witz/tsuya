<script lang="ts">
  import { Thumbnail } from '@tsuya/svelte';

  import { COVER } from '#lib/examples/art.ts';
</script>

<Thumbnail src={COVER.teal} alt="40 wide" size={40} />
<Thumbnail src={COVER.teal} alt="64 wide" size={64} />
<Thumbnail src={COVER.teal} alt="120 wide" size={120} />
