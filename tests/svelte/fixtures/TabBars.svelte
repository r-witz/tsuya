<!-- A phone screen with a tall page and a tab bar of four tabs in its dock, one with a badge. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Screen, TabBar, TsuyaProvider, type TabBarItem } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    value?: string;
    dir?: 'ltr' | 'rtl';
    /** Five tabs with long labels. */
    crowded?: boolean;
    /** The screen inside a 400 tall scroll container, as in a docs preview, over a tall page. */
    scroller?: boolean;
  }

  let { value = $bindable(), dir = 'ltr', crowded = false, scroller = false }: Props = $props();

  const items: TabBarItem[] = $derived([
    { value: 'home', label: 'Home', icon: home },
    { value: 'library', label: crowded ? 'Your music library' : 'Library', icon: library },
    { value: 'inbox', label: 'Inbox', icon: inbox, badge: { count: 3, label: '3 new' } },
    { value: 'settings', label: 'Settings', icon: settings },
    ...(crowded ? [{ value: 'profile', label: 'Profile and account', icon: home }] : []),
  ]);
</script>

{#snippet home()}<svg viewBox="0 0 24 24" data-testid="icon"><path d="M4 11l8-7 8 7v9H4z" /></svg>{/snippet}
{#snippet library()}<svg viewBox="0 0 24 24"><path d="M5 4h4v16H5zM11 4h4v16h-4z" /></svg>{/snippet}
{#snippet inbox()}<svg viewBox="0 0 24 24"><path d="M4 5h16v14H4z" /></svg>{/snippet}
{#snippet settings()}<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="4" /></svg>{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div {dir} data-testid="scroller" style={scroller ? 'height: 400px; overflow-y: auto' : undefined}>
    <Screen>
      {#each Array.from({ length: 30 }, (_, i) => i) as row (row)}<p>Row {row + 1}</p>{/each}
      {#snippet dock()}<TabBar bind:value {items} aria-label="Sections" />{/snippet}
    </Screen>
  </div>
  {#if scroller}<div style="height: 2000px"></div>{/if}
  <output data-testid="value">{value}</output>
</TsuyaProvider>
