<!--
  @component
  Tabs (DESIGN.md, Tabs): the selected value, bound, and the parts inside, Tabs.List with its Tabs.Trigger and a
  Tabs.Content for each. The arrows select as they move, unless `manual`: then Enter and Space do.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  import { setTabs, TabsState } from './state.svelte.ts';

  interface Props extends HTMLAttributes<HTMLDivElement> {
    /** The value of the selected tab; the first tab is selected while it is undefined. */
    value?: string;
    /** Arrows move focus only; Enter and Space select. */
    manual?: boolean;
    /** Its list and panels. */
    children: Snippet;
  }

  let { value = $bindable(), manual = false, class: className, children, ...rest }: Props = $props();

  const id = $props.id();
  setTabs(
    new TabsState({
      id,
      value: () => value,
      setValue: (next) => (value = next),
      manual: () => manual,
    }),
  );
</script>

<div {...rest} class={['t-tabs', className]}>
  {@render children()}
</div>
