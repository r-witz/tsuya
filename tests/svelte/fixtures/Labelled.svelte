<!-- A component that shows a system string, as Dialog shows "Close". -->
<script lang="ts">
  import { getLabels } from '../../../packages/svelte/src/lib/primitives/labels.ts';

  const labels = getLabels('Labelled');
</script>

<button type="button">{labels.close}</button>
