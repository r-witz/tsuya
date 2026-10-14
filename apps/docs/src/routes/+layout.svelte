<!--
  The docs shell (made of tsuya's own components): TsuyaProvider, a TopBar whose
  links fold into a menu below the tablet width, a Sidebar with the page tree from the desktop breakpoint, and the
  content column at most --t-container-max-width. The whole shell is one AccentRegion and one Surface, so the home
  page's picked cover can tint the glass of the TopBar itself and light the top of the page (DESIGN.md, Surface).
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import { resolve } from '$app/paths';
  import '@tsuya/core/tsuya.css';
  import '@tsuya/core/fonts.css';
  import '../app.css';

  import { page } from '$app/state';
  import {
    AccentRegion,
    Ambient,
    IconButton,
    Menu,
    Sidebar,
    SidebarGroup,
    SidebarItem,
    Surface,
    TsuyaProvider,
    TopBar,
  } from '@tsuya/svelte';
  import { labelsEn } from '@tsuya/core';

  import { NAV, PAGES, TOP_LINKS } from '#lib/content/nav.ts';
  import { site, type SiteMode } from '#lib/doc/site-mode.svelte.ts';
  import Icon from '#lib/icons/Icon.svelte';
  import { homeAccent } from '#lib/material/home-accent.svelte.ts';

  let { children }: { children: Snippet } = $props();

  // TopBar has no prop to name the <nav> of its links, and the component pages show TopBars of their own: two
  // unnamed navigation landmarks on one page break axe's "landmark-unique", so the shell's is named here
  const nameLinks = (bar: HTMLElement) => bar.querySelector('nav.t-top-bar-links')?.setAttribute('aria-label', 'Site');

  // a plain string, not the narrower union: Menu.RadioGroup's value is typed as string, since its items are
  const mode = {
    get value(): string {
      return site.mode;
    },
    set value(next: string) {
      site.mode = next as SiteMode;
    },
  };
  // the Playwright specs wait for this rather than for the network to go quiet: the layout's effects run after its
  // pages', so once it is set the whole page is hydrated and its controls answer
  $effect(() => {
    document.documentElement.dataset['hydrated'] = '';
  });
  const path = $derived(page.url.pathname.replace(/^\/|\/$/g, ''));
  const description = $derived(PAGES.find((entry) => entry.slug === path)?.summary);
  // the TopBar's links are a handful of sections: the current one also covers its own sub-pages
  const topLinks = $derived(
    TOP_LINKS.map((l) => ({
      href: `/${l.slug}`,
      label: l.title,
      current: path === l.slug || path.startsWith(`${l.slug}/`),
    })),
  );
</script>

<svelte:head>
  {#if description}<meta name="description" content={description} />{/if}
</svelte:head>

<TsuyaProvider mode={site.mode} labels={labelsEn}>
  <!-- the first stop of the page: hidden above the window until it has focus -->
  <a class="skip t-label" href="#main">Skip to main content</a>
  <AccentRegion pair={homeAccent.pair} style="display: contents">
    <Surface class="shell">
      <Ambient src={homeAccent.src} opacity={homeAccent.pair?.ambient} />
      <TopBar links={topLinks} {@attach nameLinks}>
        {#snippet start()}<a class="brand t-title-s" href={resolve('/')}>tsuya</a>{/snippet}
        {#snippet end()}
          <!-- the mode is a menu behind one icon: three segments and a labelled button did not fit a bar of the tablet width -->
          <Menu.Root>
            <Menu.Trigger>
              {#snippet child(props)}
                <IconButton {...props} label="Mode" variant="plain">
                  {#snippet icon()}<Icon name="sun" />{/snippet}
                </IconButton>
              {/snippet}
            </Menu.Trigger>
            <Menu.Content>
              <Menu.RadioGroup label="Mode" bind:value={mode.value}>
                <Menu.RadioItem value="system">System</Menu.RadioItem>
                <Menu.RadioItem value="light">Light</Menu.RadioItem>
                <Menu.RadioItem value="dark">Dark</Menu.RadioItem>
              </Menu.RadioGroup>
            </Menu.Content>
          </Menu.Root>
        {/snippet}
      </TopBar>
      <div class="layout">
        <Sidebar class="nav" aria-label="Pages">
          {#each NAV as group (group.label)}
            <SidebarGroup label={group.label}>
              {#each group.entries as entry (entry.slug)}
                <!-- the page tree: only the exact page is current, unlike the TopBar's broader section links -->
                <SidebarItem href={`/${entry.slug}`} current={path === entry.slug}>{entry.title}</SidebarItem>
              {/each}
            </SidebarGroup>
          {/each}
        </Sidebar>
        <main class="content" id="main" tabindex="-1">
          {@render children()}
        </main>
      </div>
    </Surface>
  </AccentRegion>
</TsuyaProvider>

<style>
  :global(.shell) {
    min-height: 100vh;
  }
  .skip {
    position: fixed;
    inset-block-start: var(--t-space-12);
    inset-inline-start: var(--t-space-12);
    z-index: 10;
    padding: var(--t-space-12) var(--t-space-16);
    border: 1px solid var(--t-border-strong);
    border-radius: var(--t-radius-md);
    background: var(--t-bg);
    color: var(--t-text);
    text-decoration: none;
    transform: translateY(calc(-100% - var(--t-space-24)));
  }
  .skip:focus {
    transform: none;
    outline: var(--t-state-focus-width) solid var(--t-accent);
    outline-offset: var(--t-state-focus-offset);
  }
  /* it takes focus from the skip link, which is no reason for a ring around the whole page */
  .content:focus {
    outline: none;
  }
  .brand {
    padding-inline: var(--t-space-12);
    color: var(--t-text);
    text-decoration: none;
  }
  .layout {
    display: block;
  }
  /* :global: "nav" is a class passed to <Sidebar>'s own root, not written on an element of this template */
  :global(.nav) {
    display: none;
  }
  /* air under a page's title block, and above and below each section's heading: headings carry no margin of their own.
     Direct children only: a PageHeader shown on a stage is part of an example, not of the page. */
  .content > :global(.t-page-header) {
    margin-block-end: var(--t-space-16);
  }
  .content > :global(h2.t-title-l) {
    margin-block: var(--t-space-48) var(--t-space-16);
  }
  .content {
    box-sizing: border-box;
    /* a grid item with auto margins is as wide as its content's min-content, up to its track: a wide table or code
       block, which scrolls in its own box, would still push it past the track. Its width is the track's. */
    width: 100%;
    min-width: 0;
    max-width: var(--t-container-max-width);
    margin-inline: auto;
    padding: var(--t-space-24) var(--t-container-gutter-phone) var(--t-space-64);
  }
  @media (min-width: 600px) {
    .content {
      padding-inline: var(--t-container-gutter-tablet);
    }
  }
  /* the desktop breakpoint: a media feature cannot read a custom property, so --t-breakpoint-desktop's own 1024px
     value is repeated here, as components/header/PageHeader.svelte already does */
  @media (min-width: 1024px) {
    .layout {
      display: grid;
      grid-template-columns: 240px minmax(0, 1fr);
      align-items: start;
    }
    :global(.nav) {
      display: flex;
      position: sticky;
      /* below the floating, 56px-tall TopBar and its 12px margin, plus a little more air */
      top: calc(var(--t-size-bar) + var(--t-space-24));
    }
    .content {
      padding-inline: var(--t-container-gutter-desktop);
    }
  }
</style>
