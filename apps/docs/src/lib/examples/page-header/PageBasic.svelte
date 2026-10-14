<script lang="ts">
  import { Button, PageHeader } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <PageHeader title="Albums" subtitle="412 albums · 3,208 tracks">
    {#snippet actions()}<Button variant="secondary">Sort</Button>{/snippet}
  </PageHeader>
</div>
