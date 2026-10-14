<!--
  @component
  The control that opens a menu or a popover: a tsuya Button with the opener's props, or the app's own element (an
  icon button) through `child`, which receives them to spread.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  import Button from '../components/button/Button.svelte';
  import type { ButtonProps } from '../components/button/types.ts';

  type Props = ButtonProps & {
    /** What the opener needs: its id, ARIA, handlers and an attachment. */
    opener: Record<string | symbol, unknown>;
    /** The app's own opener; spread the props it receives on its element. */
    child?: Snippet<[Record<string | symbol, unknown>]>;
  };

  let { opener, child, children, ...rest }: Props = $props();
</script>

{#if child}
  {@render child(opener)}
{:else}
  <Button {...rest} {...opener}>{@render children?.()}</Button>
{/if}
