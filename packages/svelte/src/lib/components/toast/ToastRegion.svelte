<!--
  @component
  The toast region (DESIGN.md, Toast): TsuyaProvider renders it once; `toast()` fills it. Glass, role="status"
  (not live: `toast()` announces the message through the live announcer), bottom centre, above a `.t-tab-bar` where
  one exists. Without an action it leaves after `--t-duration-toast` (paused while hovered or focused); with an action
  (a small ghost button) it also has a close button and stays until used, Escape, or replaced. F6 moves focus to it
  while one is shown; focus returns when it goes. A swipe down, on touch, dismisses it. Always above a dialog or a
  sheet, however the two are opened in turn: a modal dialog paints above a popover regardless of order (checked
  directly), so the toast portals into the topmost one instead of trying to out-rank it (@tsuya/core/primitives,
  `currentHost`).
-->
<script lang="ts">
  import { currentHost, dismissable, focusReturn, swipeDown, watchHosts } from '@tsuya/core/primitives';

  import { getLabels } from '../../primitives/labels.ts';
  import { durationOf } from '../../primitives/motion.svelte.ts';
  import { presence } from '../../primitives/presence.ts';
  import Glyph from '../../internal/Glyph.svelte';
  import Button from '../button/Button.svelte';
  import IconButton from '../button/IconButton.svelte';
  import { dismissToast, toastState } from './state.svelte.ts';

  const labels = getLabels('Toast');

  // leaves on its own after --t-duration-toast, unless it has an action; paused while hovered or focused. How long
  // a toast stays is not a motion duration: reduced motion shortens an animation, not how long there is to read a
  // message, so it is read as it is, not through duration().
  function autoDismiss(id: number, hasAction: boolean) {
    return (node: HTMLElement) => {
      if (hasAction) return undefined;
      let remaining = durationOf(node, 'toast', 4000);
      let since = performance.now();
      let timer = setTimeout(() => {
        dismissToast(id);
      }, remaining);
      function pause() {
        clearTimeout(timer);
        remaining -= performance.now() - since;
      }
      function resume() {
        since = performance.now();
        timer = setTimeout(
          () => {
            dismissToast(id);
          },
          Math.max(0, remaining),
        );
      }
      node.addEventListener('pointerenter', pause);
      node.addEventListener('pointerleave', resume);
      node.addEventListener('focusin', pause);
      node.addEventListener('focusout', resume);
      return () => {
        clearTimeout(timer);
        node.removeEventListener('pointerenter', pause);
        node.removeEventListener('pointerleave', resume);
        node.removeEventListener('focusin', pause);
        node.removeEventListener('focusout', resume);
      };
    };
  }

  // F6 (the documented shortcut, DESIGN.md) reaches it; focus returns to the opener when it goes, as a focus scope
  // restores (only if it was in the toast, or lost to the page), but never steals focus on its own
  function focusBehaviour(node: HTMLElement) {
    const giveBack = focusReturn(node);
    function onkeydown(event: KeyboardEvent) {
      if (event.key !== 'F6' || event.defaultPrevented) return;
      event.preventDefault();
      node.focus();
    }
    document.addEventListener('keydown', onkeydown);
    return () => {
      document.removeEventListener('keydown', onkeydown);
      giveBack();
    };
  }

  // a popover on its own (above everything but a modal), or a plain child of the topmost modal dialog or sheet
  // (above its own backdrop too, which a popover cannot out-rank): placed again whenever one opens or closes
  function portal(node: HTMLElement) {
    function place() {
      const active = document.activeElement;
      const refocus = active instanceof HTMLElement && node.contains(active);
      if (node.matches(':popover-open')) node.hidePopover();
      const host = currentHost();
      if (host) {
        // a popover left "manual" but unopened is display: none by its own UA stylesheet rule
        node.removeAttribute('popover');
        host.append(node);
      } else {
        node.popover = 'manual';
        document.body.append(node);
        node.showPopover();
      }
      if (refocus) active.focus();
    }
    place();
    const stopWatching = watchHosts(place);
    return () => {
      stopWatching();
      if (node.matches(':popover-open')) node.hidePopover();
      // moved out of wherever Svelte rendered it (document.body, or a host): its own teardown must also remove it
      node.remove();
    };
  }
</script>

{#if toastState.current}
  {@const current = toastState.current}
  {#key current.id}
    <div
      role="status"
      aria-live="off"
      tabindex="-1"
      class="t-toast t-glass"
      data-shadow="md"
      transition:presence={{ y: 16 }}
      {@attach portal}
      {@attach focusBehaviour}
      {@attach autoDismiss(current.id, Boolean(current.action))}
      {@attach dismissable({
        ondismiss: () => {
          dismissToast(current.id);
        },
        focusOutside: false,
        outsidePress: false,
      })}
      {@attach swipeDown({
        ondismiss: () => {
          dismissToast(current.id);
        },
      })}
    >
      {#if current.icon}<Glyph name={current.icon} />{/if}
      <p class="t-toast-message">{current.message}</p>
      {#if current.action}
        <Button
          variant="ghost"
          size="sm"
          onclick={() => {
            current.action?.onclick();
            dismissToast(current.id);
          }}
        >
          {current.action.label}
        </Button>
        <IconButton
          label={labels.dismiss}
          variant="plain"
          size="sm"
          onclick={() => {
            dismissToast(current.id);
          }}
        >
          {#snippet icon()}<Glyph name="close" />{/snippet}
        </IconButton>
      {/if}
    </div>
  {/key}
{/if}
