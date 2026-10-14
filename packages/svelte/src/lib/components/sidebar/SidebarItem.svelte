<!--
  @component
  A sidebar item (DESIGN.md, Sidebar): `--t-size-control-sm` tall (`--t-size-target` on touch), `--t-radius-sm`, an
  icon and its label in `--t-type-control` `--t-text-muted`, a count at the end; the current one, `aria-current`, in
  `--t-text` on `--t-fill-strong`. A link with `href`, a button otherwise. Collapsed, the icon only, named by its
  label, which shows as a tooltip at its end.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAnchorAttributes } from 'svelte/elements';

  import Tooltip from '../tooltip/Tooltip.svelte';
  import { getCollapsed } from './state.ts';

  interface Props extends Omit<HTMLAnchorAttributes, 'children'> {
    /** Where it leads. */
    href?: string;
    /** An icon before the label. */
    icon?: Snippet;
    /** A number at the end, such as the unread items. */
    count?: number;
    /** The page it leads to is the current one. */
    current?: boolean;
    /** Called when it is pressed. */
    onclick?: (event: MouseEvent) => void;
    /** The label. */
    children: Snippet;
  }

  let { href, icon, count, current = false, class: className, children, ...rest }: Props = $props();

  const collapsed = getCollapsed();

  // the text of the label, for its tooltip, kept as it changes
  let text = $state('');
  function read(node: HTMLElement) {
    const update = () => {
      text = node.textContent.trim();
    };
    update();
    const observer = new MutationObserver(update);
    observer.observe(node, { characterData: true, childList: true, subtree: true });
    return () => {
      observer.disconnect();
    };
  }
</script>

<!-- the same element collapsed or not, so that an item which collapses its sidebar keeps the focus -->
{#snippet item(tooltip: Record<string | symbol, unknown>)}
  <svelte:element
    this={href === undefined ? 'button' : 'a'}
    {...rest}
    {...collapsed() ? tooltip : {}}
    {href}
    type={href === undefined ? 'button' : undefined}
    aria-current={current ? 'page' : undefined}
    data-press="highlight"
    class={['t-sidebar-item', 't-pressable', collapsed() && 't-sidebar-item-collapsed', className]}
  >
    {#if icon}<span class="t-sidebar-item-icon">{@render icon()}</span>{/if}
    <span class={['t-sidebar-item-label', collapsed() && 't-sidebar-item-read-only']} {@attach read}
      >{@render children()}</span
    >
    {#if count !== undefined && !collapsed()}<span class="t-sidebar-item-count">{count}</span>{/if}
  </svelte:element>
{/snippet}

<Tooltip {text} label side="end" trigger={item} />
