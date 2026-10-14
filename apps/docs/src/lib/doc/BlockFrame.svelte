<!--
  The frame of a block's live example: it shows each block in light and dark, at phone and desktop widths. A Screen,
  a TopBar or a Sidebar is a shell: left to itself it would take over the docs' own page. The frame is a box of a
  phone's or a desktop's width, with its own scroll and its own `data-theme`, that contains them: it is a
  containing block for fixed and sticky descendants (`contain: layout`), and a Screen fills it instead of the window.
-->
<script lang="ts">
  import { SegmentedControl } from '@tsuya/svelte';
  import { untrack, type Snippet } from 'svelte';

  interface Props {
    /** The width it opens at. */
    width?: 'phone' | 'desktop';
    label: string;
    children: Snippet;
  }

  let { width: initial = 'phone', label, children }: Props = $props();

  // plain strings, not the narrower unions: SegmentedControl's value is typed as string, since its options are.
  // The width a block opens at is its initial value only.
  let width = $state<string>(untrack(() => initial));
  let mode = $state<string>('light');
  let frame = $state<HTMLElement | null>(null);

  // TopBar's links are a <nav> that takes no name (it is not a prop of the bar), and the docs' own bar has one too:
  // two landmarks with the same name. Inside the frame, the example's gets one.
  $effect(() => {
    const root = frame;
    if (!root) return;
    const name = () => {
      for (const nav of root.querySelectorAll('nav:not([aria-label], [aria-labelledby])'))
        nav.setAttribute('aria-label', 'Example navigation');
    };
    name();
    const observer = new MutationObserver(name);
    observer.observe(root, { childList: true, subtree: true });
    return () => {
      observer.disconnect();
    };
  });
</script>

<div class="controls">
  <SegmentedControl
    label="Example mode"
    bind:value={mode}
    options={[
      { value: 'light', label: 'Light' },
      { value: 'dark', label: 'Dark' },
    ]}
  />
  <SegmentedControl
    label="Example width"
    bind:value={width}
    options={[
      { value: 'phone', label: 'Phone 390' },
      { value: 'desktop', label: 'Desktop 1024' },
    ]}
  />
</div>
<!-- a region that scrolls must take the keyboard (axe: scrollable-region-focusable), so both are tab stops -->
<!-- svelte-ignore a11y_no_noninteractive_tabindex -->
<div class="scroller" role="region" aria-label={`${label}: sideways scroll`} tabindex="0">
  <!-- svelte-ignore a11y_no_noninteractive_tabindex -->
  <div
    class="frame"
    bind:this={frame}
    data-theme={mode}
    data-width={width}
    role="region"
    aria-label={label}
    tabindex="0"
  >
    {@render children()}
  </div>
</div>

<style>
  .controls {
    display: flex;
    flex-wrap: wrap;
    gap: var(--t-space-12);
    margin-bottom: var(--t-space-16);
  }
  .scroller {
    overflow-x: auto;
    padding-bottom: var(--t-space-4);
  }
  .frame {
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
    height: 780px;
    overflow: auto;
    contain: layout;
    border: 1px solid var(--t-border-strong);
    border-radius: var(--t-radius-lg);
    background: var(--t-bg);
    color: var(--t-text);
  }
  .frame[data-width='phone'] {
    width: 392px;
    max-width: 100%;
  }
  .frame[data-width='desktop'] {
    width: 1026px;
    height: 640px;
  }
  /* the example is the frame's screen: it fills it, and a Screen's own full-window height gives way to it */
  .frame > :global(*),
  .frame :global(.t-surface) {
    flex: 1 0 auto;
  }
  .frame :global(.t-screen) {
    min-height: 0;
  }
</style>
