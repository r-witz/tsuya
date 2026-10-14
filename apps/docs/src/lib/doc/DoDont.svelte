<!--
  A do/don't pair with visuals: two small live stages, side by side.
-->
<script lang="ts">
  import type { Snippet } from 'svelte';

  interface Props {
    doCaption: string;
    dontCaption: string;
    doExample: Snippet;
    dontExample: Snippet;
  }

  let { doCaption, dontCaption, doExample, dontExample }: Props = $props();
</script>

<div class="do-dont">
  <figure class="good">
    <div class="stage">{@render doExample()}</div>
    <figcaption><strong class="t-body-strong">Do</strong> <span class="t-small t-muted">{doCaption}</span></figcaption>
  </figure>
  <figure class="bad">
    <div class="stage">{@render dontExample()}</div>
    <figcaption>
      <strong class="t-body-strong">Don't</strong> <span class="t-small t-muted">{dontCaption}</span>
    </figcaption>
  </figure>
</div>

<style>
  .do-dont {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: var(--t-space-16);
    margin-top: var(--t-space-16);
  }
  figure {
    margin: 0;
  }
  .stage {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: var(--t-space-8);
    min-height: var(--t-size-control-lg);
    padding: var(--t-space-16);
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
    background: var(--t-fill);
  }
  .good .stage {
    outline: 1px solid var(--t-success);
    outline-offset: -1px;
  }
  .bad .stage {
    outline: 1px solid var(--t-danger);
    outline-offset: -1px;
  }
  figcaption {
    margin-top: var(--t-space-8);
  }
</style>
