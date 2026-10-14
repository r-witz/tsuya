<!-- An app shell with the material: a provider, a surface lit by an image or the glow, an accent region with glass. -->
<script lang="ts">
  import {
    AccentRegion,
    Ambient,
    GlassScope,
    Glow,
    Surface,
    TsuyaProvider,
  } from '../../../packages/svelte/src/lib/index.ts';
  import type { ImageAccent, RegionPair, TsuyaLabels } from '../../../packages/core/src/index.ts';

  interface Props {
    mode?: 'system' | 'light' | 'dark';
    labels: TsuyaLabels;
    pair: (RegionPair & Partial<Pick<ImageAccent, 'ambient'>>) | null;
    src?: string | null;
    neutral?: boolean;
    reduce?: boolean;
    grain?: 'bg' | 'all' | 'off';
    glow?: boolean;
  }

  let { mode = 'system', labels, pair, src = null, neutral, reduce, grain = 'bg', glow = false }: Props = $props();
</script>

<TsuyaProvider {mode} {labels}>
  <Surface data-testid="surface" {grain} style="height: 400px">
    {#if glow}<Glow />{:else}<Ambient {src} opacity={pair?.ambient} />{/if}
    <AccentRegion {pair} data-testid="region">
      <p data-testid="probe" style="color: var(--t-accent)">Accent</p>
      <GlassScope {neutral} {reduce}>
        <div class="t-glass" data-testid="glass">Glass</div>
      </GlassScope>
    </AccentRegion>
  </Surface>
</TsuyaProvider>
