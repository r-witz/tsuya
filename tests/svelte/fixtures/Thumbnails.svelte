<!-- Thumbnails: a loaded picture, a placeholder without one, a broken image, the three ratios and the four radius tiers. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { TsuyaProvider, Thumbnail } from '../../../packages/svelte/src/lib/index.ts';
  import type { TsuyaLabels } from '../../../packages/core/src/labels.ts';

  const PIXEL =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=';

  interface Props {
    labels?: TsuyaLabels;
    src?: string;
  }

  let { labels = labelsEn, src = PIXEL }: Props = $props();
</script>

{#snippet photoIcon()}
  <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" data-testid="placeholder-icon"
    ><rect x="4" y="4" width="16" height="16" /></svg
  >
{/snippet}

{#snippet bareIcon()}
  <svg viewBox="0 0 24 24" aria-hidden="true"><rect x="4" y="4" width="16" height="16" /></svg>
{/snippet}

<TsuyaProvider {labels}>
  <div style="display:flex; flex-wrap:wrap; align-items:flex-start; gap: var(--t-space-16); padding: var(--t-space-16)">
    <Thumbnail {src} alt="Album cover" data-testid="loaded" />
    <Thumbnail {src} data-testid="no-alt" />
    <Thumbnail data-testid="empty" icon={photoIcon} />
    <Thumbnail src="/does-not-exist.png" data-testid="broken" icon={photoIcon} />
    <Thumbnail data-testid="bare-icon" icon={bareIcon} />
    <Thumbnail {src} ratio="portrait" data-testid="portrait" />
    <Thumbnail {src} ratio="wide" data-testid="wide" />
    <Thumbnail {src} size={32} data-testid="xs" />
    <Thumbnail {src} size={64} data-testid="sm" />
    <Thumbnail {src} size={160} data-testid="md" />
    <Thumbnail {src} size={200} data-testid="lg" />
  </div>
</TsuyaProvider>
