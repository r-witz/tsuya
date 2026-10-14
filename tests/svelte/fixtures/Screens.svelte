<!-- A phone screen: a long page of rows, lit by an image or by the glow, with a dock at the bottom. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Screen, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    ambient?: string | null;
    rows?: number;
    /** A dock as tall as a tab bar gets at 400 % zoom. */
    tall?: boolean;
  }

  let { ambient = null, rows = 40, tall = false }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <Screen {ambient} data-testid="screen">
    <h1 style="margin: 0">Library</h1>
    {#each Array.from({ length: rows }, (_, i) => i + 1) as row (row)}
      <p data-testid="row-{row}">Row {row}</p>
    {/each}
    {#snippet dock()}
      <div
        class="t-glass"
        data-testid="dock"
        style="min-height: {tall ? '260px' : 'var(--t-size-dock)'}; border-radius: var(--t-radius-lg)"
      >
        Dock
      </div>
    {/snippet}
  </Screen>
</TsuyaProvider>
