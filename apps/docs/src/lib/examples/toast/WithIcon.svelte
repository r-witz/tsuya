<script lang="ts">
  import { Button, toast } from '@tsuya/svelte';
</script>

<Button
  variant="secondary"
  onclick={() => {
    toast('Link copied', { icon: 'check' });
  }}>Copy link</Button
>
