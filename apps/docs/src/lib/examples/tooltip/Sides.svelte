<script lang="ts">
  import { Button, Tooltip } from '@tsuya/svelte';
</script>

{#each ['top', 'bottom', 'start', 'end'] as const as side (side)}
  <Tooltip text={`Shown on the ${side} side`} {side}>
    {#snippet trigger(props)}
      <Button variant="ghost" {...props}>{side}</Button>
    {/snippet}
  </Tooltip>
{/each}
