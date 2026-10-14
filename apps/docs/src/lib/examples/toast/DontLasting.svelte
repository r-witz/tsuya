<!-- Don't: being offline lasts, and a toast leaves after a few seconds; this is a banner (DESIGN.md, Banner: "A lasting state"). -->
<script lang="ts">
  import { Button, toast } from '@tsuya/svelte';
</script>

<Button
  variant="secondary"
  onclick={() => {
    toast('You are offline. Changes sync when you are back online.');
  }}
>
  Go offline
</Button>
