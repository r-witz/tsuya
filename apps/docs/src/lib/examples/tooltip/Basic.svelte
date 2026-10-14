<script lang="ts">
  import { Button, Tooltip } from '@tsuya/svelte';
</script>

<Tooltip text="Saves a draft. Nothing is published.">
  {#snippet trigger(props)}
    <Button variant="secondary" {...props}>Save draft</Button>
  {/snippet}
</Tooltip>
