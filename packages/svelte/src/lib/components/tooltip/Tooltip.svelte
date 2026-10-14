<!--
  @component
  A tooltip (DESIGN.md, Tooltip): a short label for its trigger on fine pointers, after `--t-duration-tooltip-delay`,
  and at once on keyboard focus; never on touch, never essential. Inverted (`--t-text` with `--t-bg` text),
  `--t-radius-xs`, padding 4 8, `--t-type-caption`, at most 240 wide, above its trigger. It stays while the pointer is
  over it; Escape and a press hide it, and the Escape stops there only when its trigger has the focus. It describes
  its trigger (`aria-describedby`), or with `label` it repeats the trigger's own name and stays out of the
  accessibility tree, as for icon buttons.
-->
<script lang="ts">
  import { anchored, type Side } from '@tsuya/core/primitives';
  import type { Snippet } from 'svelte';
  import { createAttachmentKey } from 'svelte/attachments';

  import { durationOf } from '../../primitives/motion.svelte.ts';

  interface Props {
    /** What it says. */
    text: string;
    /** The text is the trigger's own name (an icon button's label): it does not describe it again. */
    label?: boolean;
    /** Where it shows. Default 'top'. */
    side?: Side;
    /** The trigger, with the props to spread on its element. */
    trigger: Snippet<[Record<string | symbol, unknown>]>;
  }

  let { text, label = false, side = 'top', trigger }: Props = $props();

  const id = $props.id();
  let open = $state(false);
  let anchor = $state<HTMLElement | null>(null);
  let tip = $state<HTMLDivElement | null>(null);
  let timer: ReturnType<typeof setTimeout> | undefined;

  const ms = (name: string) => (anchor ? durationOf(anchor, name) : 0);
  const later = (next: boolean, delay: number) => {
    clearTimeout(timer);
    timer = setTimeout(() => (open = next), delay);
  };
  const now = (next: boolean) => {
    clearTimeout(timer);
    open = next;
  };

  // the pointer may cross to the tooltip and stay over it
  const leave = () => {
    later(false, ms('fast'));
  };
  const stay = () => {
    clearTimeout(timer);
  };

  const key = createAttachmentKey();
  function attach(node: HTMLElement) {
    anchor = node;
    // fine pointers, a mouse or a pen
    const enter = (event: PointerEvent) => {
      if (event.pointerType !== 'touch') later(true, open ? 0 : ms('tooltip-delay'));
    };
    const focus = () => {
      if (node.matches(':focus-visible')) now(true);
    };
    const hide = () => {
      now(false);
    };
    node.addEventListener('pointerenter', enter);
    node.addEventListener('pointerleave', leave);
    node.addEventListener('focus', focus);
    node.addEventListener('blur', hide);
    node.addEventListener('pointerdown', hide);
    return () => {
      node.removeEventListener('pointerenter', enter);
      node.removeEventListener('pointerleave', leave);
      node.removeEventListener('focus', focus);
      node.removeEventListener('blur', hide);
      node.removeEventListener('pointerdown', hide);
      // a trigger that lets it go (a sidebar item that no longer shows its icon only) hides it
      now(false);
      anchor = null;
    };
  }

  const triggerProps = $derived({ 'aria-describedby': label ? undefined : id, [key]: attach });

  $effect(() => {
    if (!tip) return;
    if (open && !tip.matches(':popover-open')) tip.showPopover();
    else if (!open && tip.matches(':popover-open')) tip.hidePopover();
  });

  // Escape hides it; on the control that has the focus, before a panel or dialog around it hears the key, which a
  // tooltip the pointer shows elsewhere lets through
  $effect(() => {
    if (!open) return;
    const onkeydown = (event: KeyboardEvent) => {
      if (event.key !== 'Escape') return;
      if (anchor?.contains(document.activeElement)) event.preventDefault();
      now(false);
    };
    document.addEventListener('keydown', onkeydown, true);
    return () => {
      document.removeEventListener('keydown', onkeydown, true);
    };
  });
</script>

{@render trigger(triggerProps)}
<div
  bind:this={tip}
  {id}
  role="tooltip"
  popover="manual"
  aria-hidden={label || undefined}
  class="t-tooltip"
  onpointerenter={stay}
  onpointerleave={leave}
  {@attach open && anchored({ anchor: () => anchor, side, align: 'center' })}
>
  {text}
</div>
