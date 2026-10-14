<!-- A bottom sheet or a side one, opened by its own button; glass when it sits inside a glass surface. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, Sheet, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    open?: boolean;
    side?: 'bottom' | 'end';
    glass?: boolean;
    dir?: 'ltr' | 'rtl';
  }

  let { open = $bindable(false), side = 'bottom', glass = false, dir = 'ltr' }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <div {dir} class={glass ? 't-glass-control' : undefined} style="padding: var(--t-space-16)">
    <Button onclick={() => (open = true)}>Share</Button>
    <Sheet.Root bind:open {side}>
      <Sheet.Content data-testid="content">
        <Sheet.Title>Share album</Sheet.Title>
        <p>Send a link to this album.</p>
        <Button onclick={() => (open = false)}>Done</Button>
      </Sheet.Content>
    </Sheet.Root>
  </div>
</TsuyaProvider>
