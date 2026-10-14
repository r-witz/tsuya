<!-- Avatars: a photo, initials on fill, a gradient that passes (order-independent), one that fails and falls back,
     a broken photo, and one with no label at all. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Avatar, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  const PIXEL =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

  interface Props {
    labels?: TsuyaLabels;
  }

  let { labels = labelsEn }: Props = $props();
</script>

<TsuyaProvider {labels}>
  <div style="display:flex; flex-wrap:wrap; align-items:flex-start; gap: var(--t-space-16); padding: var(--t-space-16)">
    <Avatar src={PIXEL} label="Jamie Doe" data-testid="photo" />
    <Avatar initials="JD" label="Jamie Doe" data-testid="plain-initials" />
    <!-- the lighter colour first: the darker one (second) is what must be checked -->
    <Avatar initials="AL" colors={['#9a8c98', '#1a1a2e']} label="Alex Lee" data-testid="gradient-pass" />
    <Avatar initials="RK" colors={['#52ab98', '#ff6b6b']} label="Robin Kim" data-testid="gradient-fail" />
    <Avatar src="/does-not-exist.png" initials="BR" label="Bo Reyes" data-testid="broken-photo" />
    <Avatar initials="NL" data-testid="no-label" />
    <Avatar size={64} initials="SZ" label="Size test" data-testid="sized" />
  </div>
</TsuyaProvider>
