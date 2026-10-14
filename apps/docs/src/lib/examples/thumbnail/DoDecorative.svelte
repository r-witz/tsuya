<script lang="ts">
  import { List, ListItem, Thumbnail } from '@tsuya/svelte';

  import { COVER } from '#lib/examples/art.ts';
</script>

<List>
  <ListItem title="Kind of Blue" subtitle="Miles Davis">
    {#snippet leading()}<Thumbnail src={COVER.teal} size={48} />{/snippet}
  </ListItem>
</List>
