<script lang="ts">
  import { Button, toast } from '@tsuya/svelte';

  function remove() {
    toast('Photo deleted', {
      action: {
        label: 'Undo',
        onclick: () => {
          toast('Photo restored', { icon: 'check' });
        },
      },
    });
  }
</script>

<Button variant="secondary" onclick={remove}>Delete photo</Button>
