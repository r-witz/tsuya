<!-- A shop's site: a top bar with navigation links, then a pushed screen with its bar and some content. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, IconButton, ScreenBar, TsuyaProvider, TopBar } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    title?: string;
    subtitle?: string;
    back?: boolean;
    dir?: 'ltr' | 'rtl';
    onback?: () => void;
    labelled?: boolean;
    /** More links than the three, for a bar whose middle does not fit. */
    extraLinks?: number;
  }

  let {
    title = 'Order 1042',
    subtitle,
    back = true,
    dir = 'ltr',
    onback = () => {},
    labelled = false,
    extraLinks = 0,
  }: Props = $props();
</script>

{#snippet star()}<svg viewBox="0 0 24 24"><path d="M12 3l3 6 6 1-4 4 1 6-6-3-6 3 1-6-4-4 6-1z" /></svg>{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="min-height: 1600px">
    <TopBar
      data-testid="top-bar"
      links={[
        { href: '#home', label: 'Home' },
        { href: '#catalog', label: 'Catalog', current: true },
        { href: '#help', label: 'Help' },
        ...Array.from({ length: extraLinks }, (_, i) => ({
          href: `#more-${String(i)}`,
          label: `Section ${String(i + 1)}`,
        })),
      ]}
    >
      {#snippet start()}<strong>Shop</strong>{/snippet}
      {#snippet end()}
        {#if labelled}
          <Button size="sm">Sign in</Button>
        {:else}
          <IconButton label="Account" variant="plain" icon={star} />
        {/if}
      {/snippet}
    </TopBar>
    <main style="padding: 0 var(--t-space-20)">
      {#if back}
        <ScreenBar {title} {subtitle} onBack={onback} backLabel="Back" data-testid="screen-bar">
          {#snippet action()}<IconButton label="Share" variant="plain" icon={star} />{/snippet}
        </ScreenBar>
      {:else}
        <ScreenBar {title} {subtitle} data-testid="screen-bar" />
      {/if}
      <p>Two items, shipped on Monday.</p>
    </main>
  </div>
</TsuyaProvider>
