<!-- Don't: the row already says "Kind of Blue", and the alt text says it again (DESIGN.md, Thumbnail: "Decorative unless it has a label"). -->
<script lang="ts">
  import { List, ListItem, Thumbnail } from '@tsuya/svelte';

  import { COVER } from '#lib/examples/art.ts';
</script>

<List>
  <ListItem title="Kind of Blue" subtitle="Miles Davis">
    {#snippet leading()}<Thumbnail src={COVER.teal} alt="Kind of Blue" size={48} />{/snippet}
  </ListItem>
</List>
