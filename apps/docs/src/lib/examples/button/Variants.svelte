<script lang="ts">
  import { Button } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<Button variant="primary">
  {#snippet icon()}<Icon name="plus" />{/snippet}
  Primary
</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="danger">
  {#snippet icon()}<Icon name="trash" />{/snippet}
  Delete
</Button>
