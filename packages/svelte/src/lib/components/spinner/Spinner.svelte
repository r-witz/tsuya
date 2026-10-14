<!--
  @component
  A spinner (DESIGN.md, Spinner): a quarter arc in the accent turning on its track, once every 0.8 s, under reduced
  motion too: its motion is the information. Alone it is an indeterminate progress bar named with `label` (the
  `loading` label by default); with `aria-hidden`, inside a labelled button, it is only drawn, in the content colour.
-->
<script lang="ts">
  import type { HTMLAttributes } from 'svelte/elements';

  import { getLabels } from '../../primitives/labels.ts';

  interface Props extends HTMLAttributes<HTMLSpanElement> {
    /** 16, 20 or 24. Default 'md'. */
    size?: 'sm' | 'md' | 'lg';
    /** What is loading; the `loading` label by default. */
    label?: string;
  }

  let { size = 'md', label, class: className, ...rest }: Props = $props();

  const labels = getLabels('Spinner');
  const hidden = $derived(rest['aria-hidden'] === true || rest['aria-hidden'] === 'true');
</script>

<span
  {...rest}
  class={['t-spinner', `t-spinner-${size}`, className]}
  role={hidden ? undefined : 'progressbar'}
  aria-label={hidden ? undefined : (label ?? labels.loading)}
>
  <svg class="t-spinner-svg" viewBox="0 0 24 24" fill="none" aria-hidden="true" focusable="false">
    <circle class="t-spinner-circle t-spinner-track" cx="12" cy="12" r="10" />
    <circle class="t-spinner-circle t-spinner-arc" cx="12" cy="12" r="10" pathLength="4" />
  </svg>
</span>
