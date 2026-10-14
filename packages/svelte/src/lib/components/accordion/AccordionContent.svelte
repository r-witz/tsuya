<!--
  @component
  The content of an accordion item (DESIGN.md, Accordion): a region named by its header, `--t-space-16` around it.
  Its height opens and closes over `--t-duration-base`, at once under reduced motion.
-->
<script lang="ts">
  import { tick, untrack, type Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { duration } from '../../primitives/motion.svelte.ts';
  import { getAccordion, getItem } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The panel content. */
    children: Snippet;
  }

  let { class: className, children, ...rest }: Props = $props();

  const accordion = getAccordion('Content');
  const item = getItem('Content');
  const open = $derived(accordion.isOpen(item.value()));

  let region = $state<HTMLDivElement | null>(null);
  // in the layout while open, and while it closes
  let shown = $state(untrack(() => open));
  let resizing: Animation | undefined;
  let mounted = false;

  $effect(() => {
    const opening = open;
    const node = region;
    if (!node) return;
    if (!mounted) {
      mounted = true;
      return;
    }
    untrack(() => {
      const from = node.getBoundingClientRect().height;
      resizing?.cancel();
      shown = true;
      void tick().then(() => {
        const ms = duration(node, 'base');
        const to = opening ? node.scrollHeight : 0;
        if (!ms || from === to) {
          shown = opening;
          return;
        }
        const easing = getComputedStyle(node).getPropertyValue('--t-easing-standard').trim() || 'ease';
        const animation = node.animate(
          [
            { height: `${String(from)}px`, overflow: 'hidden' },
            { height: `${String(to)}px`, overflow: 'hidden' },
          ],
          { duration: ms, easing },
        );
        resizing = animation;
        animation.onfinish = () => {
          shown = opening;
          resizing = undefined;
        };
      });
    });
  });
</script>

<div
  bind:this={region}
  {...rest}
  role="region"
  id={accordion.contentId(item.value())}
  aria-labelledby={accordion.triggerId(item.value())}
  hidden={!shown}
  class={['t-accordion-content', className]}
>
  <div class="t-accordion-content-inner">{@render children()}</div>
</div>
