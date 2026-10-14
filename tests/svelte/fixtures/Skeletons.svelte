<!-- Skeletons: a row placeholder (an avatar and two lines) and paragraphs of skeleton text, in a region that loads. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Skeleton, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  interface Props {
    labels?: TsuyaLabels;
  }

  let { labels = labelsEn }: Props = $props();
</script>

<TsuyaProvider {labels}>
  <div
    style="display:flex; flex-direction:column; gap: var(--t-space-16); padding: var(--t-space-16); max-width:400px"
    data-testid="region"
    aria-busy="true"
  >
    <div style="display:flex; align-items:center; gap: var(--t-space-12)" data-testid="row">
      <Skeleton width={40} height={40} radius="full" data-testid="avatar-skeleton" />
      <div style="display:flex; flex-direction:column; gap: var(--t-space-8); flex:1">
        <Skeleton height={16} width="60%" data-testid="title-skeleton" />
        <Skeleton height={13} width="40%" data-testid="subtitle-skeleton" />
      </div>
    </div>
    <Skeleton data-testid="bare-skeleton" />
    <Skeleton.Text lines={4} data-testid="paragraph" />
    <Skeleton.Text lines={1} data-testid="single-line" />
  </div>
</TsuyaProvider>
