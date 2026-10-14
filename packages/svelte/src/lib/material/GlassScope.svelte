<!--
  @component
  How glass looks inside (DESIGN.md, Glass): `neutral` drops the accent's tint (settings, forms, grids, brand
  screens), `reduce` makes glass opaque and removes the ambient background, as the system setting does. It adds no
  box.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  interface Props {
    /** Glass without the accent's tint; false tints it again inside a neutral scope. */
    neutral?: boolean | undefined;
    /** Reduced transparency, as an app setting. */
    reduce?: boolean | undefined;
    /** What sits on the glass. */
    children: Snippet;
  }

  let { neutral, reduce, children }: Props = $props();
</script>

<div
  style:display="contents"
  data-glass={neutral === undefined ? undefined : neutral ? 'neutral' : 'tinted'}
  data-transparency={reduce ? 'reduce' : undefined}
>
  {@render children()}
</div>
