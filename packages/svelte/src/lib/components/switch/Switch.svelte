<!--
  @component
  A switch (DESIGN.md, Switch): a native checkbox with role=switch, drawn as a 48 × 28 track with a 24 thumb that
  slides to the accent-filled side when on. Applies at once. The optional `label` is drawn beside the track, in body,
  and the whole control is pressable; without one the switch is named by its ListItem row (its title, described by its
  subtitle), or needs an `aria-label` anywhere else (in development, a switch with no name warns). The focus ring sits
  on the track, around the hidden native input.
-->
<script lang="ts">
  import { DEV } from '@tsuya/svelte/env';
  import type { HTMLInputAttributes } from 'svelte/elements';

  import { getRow } from '../../internal/row.ts';

  interface Props extends Omit<HTMLInputAttributes, 'type' | 'checked' | 'role' | 'children'> {
    /** Whether it is on. */
    checked?: boolean;
    /** The text beside the track, which names it. Without one, a ListItem row names it; elsewhere, give `aria-label`. */
    label?: string;
    /** The native input. */
    ref?: HTMLInputElement | null;
  }

  let { checked = $bindable(false), label, ref = $bindable(null), class: className, ...rest }: Props = $props();

  const row = getRow();
  // the row names a switch that has no name of its own
  const named = $derived(Boolean(label) || rest['aria-label'] !== undefined || rest['aria-labelledby'] !== undefined);
  const names = $derived(named ? undefined : row());

  $effect(() => {
    if (!DEV || !ref) return;
    const hasName =
      ref.hasAttribute('aria-label') ||
      ref.hasAttribute('aria-labelledby') ||
      [...(ref.labels ?? [])].some((text) => text.textContent.trim() !== '');
    if (!hasName) {
      console.warn(
        '[tsuya] <Switch> has no accessible name. Give it a `label`, put it in a <ListItem> row, or set `aria-label`.',
      );
    }
  });
</script>

<label class={['t-switch', 't-pressable', className]} data-press="none">
  <span class="t-switch-control t-focus-within">
    <input
      bind:this={ref}
      {...rest}
      class="t-switch-input"
      bind:checked
      type="checkbox"
      role="switch"
      aria-labelledby={names?.title ?? rest['aria-labelledby']}
      aria-describedby={names?.subtitle ?? rest['aria-describedby']}
    />
    <span class="t-switch-track"></span>
    <span class="t-switch-thumb"></span>
  </span>
  {#if label}<span class="t-switch-text">{label}</span>{/if}
</label>
