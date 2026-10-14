<script lang="ts">
  import { Thumbnail } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

<Thumbnail size={64}>
  {#snippet icon()}<span style="display: flex; width: 24px; height: 24px; color: var(--t-text-muted)">
      <NavIcon name="music" />
    </span>{/snippet}
</Thumbnail>
