<script lang="ts">
  import { Popover } from '@tsuya/svelte';
</script>

<!-- Under its opener at its start edge by default; side and align move it. -->
<Popover.Root>
  <Popover.Trigger>To the end</Popover.Trigger>
  <Popover.Content side="end" align="start">
    <p class="t-body">Beside the opener.</p>
  </Popover.Content>
</Popover.Root>
