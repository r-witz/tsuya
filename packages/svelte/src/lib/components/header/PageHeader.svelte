<!--
  @component
  A page's header (DESIGN.md, PageHeader, SectionHeader): a large left-aligned title, a count line 8 below it, and
  actions at the end that wrap under the title when the header is narrow. The title grows from `display-s` to
  `display-m` from the desktop breakpoint of the header's width, or to `display-l` when `large`.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';
  import type { HTMLAttributes } from 'svelte/elements';

  interface Props extends Omit<HTMLAttributes<HTMLElement>, 'children' | 'title'> {
    /** The title. */
    title: string;
    /** The count line below the title ("412 albums · 3,208 tracks"). */
    subtitle?: string;
    /** Buttons at the end. */
    actions?: Snippet;
    /** The title in `display-l` from the desktop breakpoint, for a page that opens on it. */
    large?: boolean;
    /** The header's element. */
    ref?: HTMLElement | null;
  }

  let { title, subtitle, actions, large = false, ref = $bindable(null), class: className, ...rest }: Props = $props();
</script>

<header bind:this={ref} {...rest} class={['t-page-header', large && 't-page-header-large', className]}>
  <div class="t-page-header-heading">
    <h1 class="t-page-header-title">{title}</h1>
    {#if subtitle}<p class="t-page-header-subtitle">{subtitle}</p>{/if}
  </div>
  {#if actions}<div class="t-page-header-actions">{@render actions()}</div>{/if}
</header>
