<!-- A banner of each tone, with actions and an optional close button, at a width that fits or wraps them. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Banner, Button, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    tone?: 'info' | 'success' | 'warning' | 'danger';
    closable?: boolean;
    narrow?: boolean;
    dir?: 'ltr' | 'rtl';
    onclose?: () => void;
  }

  let { tone = 'warning', closable = false, narrow = false, dir = 'ltr', onclose = () => {} }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="padding: var(--t-space-16); width: {narrow ? '320px' : '640px'}">
    <Banner {tone} title="Sync paused" onclose={closable ? onclose : undefined}>
      Your changes will upload once you are back online.
      {#snippet actions()}
        <Button variant="secondary" size="sm">Retry</Button>
        <Button variant="ghost" size="sm">Learn more</Button>
      {/snippet}
    </Banner>
  </div>
</TsuyaProvider>
