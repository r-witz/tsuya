<!-- Progress: determinate, a thin variant, indeterminate, and one whose value can toggle between the two. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Progress, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  interface Props {
    labels?: TsuyaLabels;
    toggled?: number;
    dir?: 'ltr' | 'rtl';
  }

  let { labels = labelsEn, toggled, dir = 'ltr' }: Props = $props();
</script>

<TsuyaProvider {labels}>
  <div
    {dir}
    style="display:flex; flex-direction:column; gap: var(--t-space-16); padding: var(--t-space-16); max-width:400px"
  >
    <Progress value={0.42} label="Uploading photo.jpg" data-testid="determinate" />
    <Progress value={0.75} thin label="Downloading update" data-testid="thin" />
    <Progress label="Loading your library" data-testid="indeterminate" />
    <Progress value={toggled} label="Syncing" data-testid="toggle" />
  </div>
</TsuyaProvider>
