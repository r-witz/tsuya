<!--
  @component
  The app bar of a website or a desktop app (DESIGN.md, TopBar, ScreenBar): glass, `--t-size-bar` tall,
  `--t-radius-md`, floating `--t-space-12` from the top and sides, sticky, with `--t-shadow-md`. Snippets for the
  start (brand or back), the centre (a search) and the end (icon buttons); navigation `links` in the centre, the
  current one on `--t-fill-strong`, which move into a menu at the end below the tablet width of its container. Too
  wide for the room between start and end, the links and the centre scroll sideways; start and end that do not fit
  side by side take a row each.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import Glyph from '../../internal/Glyph.svelte';
  import { getLabels } from '../../primitives/labels.ts';
  import IconButton from '../button/IconButton.svelte';
  import { Popover } from '../popover/index.ts';

  interface Link {
    /** Where it leads. */
    href: string;
    /** Its text. */
    label: string;
    /** The page shown: `aria-current="page"`. */
    current?: boolean;
  }

  interface Props extends HTMLAttributes<HTMLElement> {
    /** At the start, before the links. */
    start?: Snippet;
    /** Navigation links, in the centre; below the tablet width of its container, in a menu at the end. */
    links?: Link[];
    /** In the centre, in place of the links. */
    center?: Snippet;
    /** At the end. */
    end?: Snippet;
  }

  let { start, links, center, end, class: className, ...rest }: Props = $props();

  const labels = getLabels('TopBar');
  let menu = $state(false);
</script>

{#snippet bars()}<Glyph name="menu" />{/snippet}

<header {...rest} class={['t-top-bar', 't-glass', className]} data-shadow="md">
  <div class="t-top-bar-start">{@render start?.()}</div>
  <div class="t-top-bar-center">
    {#if links}
      <nav class="t-top-bar-links">
        {#each links as link (link.href)}
          <a class="t-top-bar-link" href={link.href} aria-current={link.current ? 'page' : undefined}>{link.label}</a>
        {/each}
      </nav>
    {/if}
    {@render center?.()}
  </div>
  <div class="t-top-bar-end">
    {@render end?.()}
    {#if links}
      <div class="t-top-bar-compact">
        <Popover.Root bind:open={menu}>
          <Popover.Trigger>
            {#snippet child(props)}<IconButton {...props} label={labels.more} variant="plain" icon={bars} />{/snippet}
          </Popover.Trigger>
          <Popover.Content align="end">
            <nav class="t-top-bar-list">
              {#each links as link (link.href)}
                <a
                  class="t-top-bar-link"
                  href={link.href}
                  aria-current={link.current ? 'page' : undefined}
                  onclick={() => {
                    menu = false;
                  }}>{link.label}</a
                >
              {/each}
            </nav>
          </Popover.Content>
        </Popover.Root>
      </div>
    {/if}
  </div>
</header>
