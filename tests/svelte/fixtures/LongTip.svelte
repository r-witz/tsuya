<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, TsuyaProvider, Tooltip } from '../../../packages/svelte/src/lib/index.ts';
</script>

<TsuyaProvider labels={labelsEn}>
  <div style="padding: 120px 0">
    <Tooltip text="Copy the link to this photo album so that you can paste it into a message and share it with anyone">
      {#snippet trigger(props)}<Button {...props}>i</Button>{/snippet}
    </Tooltip>
  </div>
</TsuyaProvider>
