<!--
  @component
  The listbox of a select (DESIGN.md, Select): a panel anchored under the trigger, with the selected option ticked
  and the active one in view. A press in it keeps focus on the trigger, and it is no tab stop of its own. Below the
  tablet width (unless the root's `sheetOnPhone` is false) the options open in a sheet titled by the select's label
  instead: focus moves to the listbox, which takes the arrows, and goes back to the trigger when it closes.
-->
<script lang="ts">
  import type { Align, Side } from '@tsuya/core/primitives';
  import { tick, type Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';
  import { MediaQuery } from 'svelte/reactivity';

  import Panel from '../../internal/Panel.svelte';
  import { Sheet } from '../sheet/index.ts';
  import { getSelect } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The side of the trigger it opens on. */
    side?: Side;
    /** How it aligns along that side. */
    align?: Align;
    /** The panel. */
    ref?: HTMLDivElement | null;
    /** Its items and groups. */
    children: Snippet;
  }

  let {
    side = 'bottom',
    align = 'start',
    ref = $bindable(null),
    class: className,
    children,
    ...rest
  }: Props = $props();

  const select = getSelect('Content');
  // --t-breakpoint-tablet: a media feature cannot read a custom property, so the token's own value is repeated
  const phone = new MediaQuery('(width < 600px)');
  // chosen as it opens, so that a resize does not swap a panel that is open for a sheet
  let sheet = $state(false);
  $effect.pre(() => {
    if (select.open) sheet = select.props.sheetOnPhone() && phone.current;
  });

  $effect(() => {
    const id = select.listbox.activeId;
    if (!select.open || !id) return;
    // in the sheet, the dialog only shows once its attachments have run: until then nothing has a box to scroll to
    void tick().then(() => document.getElementById(id)?.scrollIntoView({ block: 'nearest' }));
  });
</script>

{#if sheet}
  <Sheet.Root
    bind:open={
      () => select.open,
      (open: boolean) => {
        select.open = open;
      }
    }
  >
    <Sheet.Content class="t-select-sheet">
      <Sheet.Title>{select.props.label()}</Sheet.Title>
      <div
        bind:this={ref}
        aria-label={select.props.label()}
        {...rest}
        id={select.listId}
        role="listbox"
        tabindex="0"
        aria-activedescendant={select.listbox.activeId}
        class={['t-select-content', className]}
        onkeydown={(event) => {
          select.listbox.keydown(event);
        }}
      >
        {@render children()}
      </div>
    </Sheet.Content>
  </Sheet.Root>
{:else}
  <Panel
    bind:ref
    aria-label={select.props.label()}
    {...rest}
    open={select.open}
    anchor={() => select.trigger}
    {side}
    {align}
    ondismiss={() => {
      select.close();
    }}
    id={select.listId}
    role="listbox"
    class={['t-select-content', className]}
    tabindex={-1}
    onmousedown={(event: MouseEvent) => {
      event.preventDefault();
    }}
  >
    {@render children()}
  </Panel>
{/if}
