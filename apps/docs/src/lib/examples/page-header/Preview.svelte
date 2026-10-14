<script lang="ts">
  import { Button, PageHeader } from '@tsuya/svelte';

  import Icon from '#lib/icons/Icon.svelte';
</script>

<div style="width: 100%">
  <PageHeader title="Albums" subtitle="412 albums · 3,208 tracks">
    {#snippet actions()}
      <Button variant="primary">
        {#snippet icon()}<Icon name="plus" />{/snippet}
        Add
      </Button>
    {/snippet}
  </PageHeader>
</div>
