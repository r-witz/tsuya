<!-- Labelled under a provider. -->
<script lang="ts">
  import { TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  import Labelled from './Labelled.svelte';

  let { labels }: { labels: TsuyaLabels } = $props();
</script>

<TsuyaProvider {labels}><Labelled /></TsuyaProvider>
