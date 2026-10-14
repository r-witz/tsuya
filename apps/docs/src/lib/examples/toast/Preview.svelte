<script lang="ts">
  import { Button, toast } from '@tsuya/svelte';
</script>

<Button
  variant="secondary"
  onclick={() => {
    toast('Saved');
  }}>Save</Button
>
