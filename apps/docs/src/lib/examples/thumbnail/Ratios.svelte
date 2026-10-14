<script lang="ts">
  import { Thumbnail } from '@tsuya/svelte';

  import { COVER } from '#lib/examples/art.ts';
</script>

<Thumbnail src={COVER.teal} alt="Square cover" size={72} />
<Thumbnail src={COVER.violet} alt="Portrait poster" size={72} ratio="portrait" />
<Thumbnail src={COVER.ember} alt="Wide still" size={128} ratio="wide" />
