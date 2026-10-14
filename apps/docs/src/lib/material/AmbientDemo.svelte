<!--
  The ambient background (DESIGN.md, Ambient background): the leading content's image, scaled, blurred and
  saturated, at the opacity accentFromImage computed for each mode. One of the built-in covers, run through the same
  engine as the home page's picker.
-->
<script lang="ts">
  import { onMount } from 'svelte';
  import { accentFromImage } from '@tsuya/core';
  import { Ambient, Surface } from '@tsuya/svelte';

  import { COVERS, renderCover } from '#lib/material/covers.ts';

  let src = $state<string | null>(null);
  let opacity = $state<{ light: number; dark: number } | undefined>(undefined);

  onMount(() => {
    const cover = COVERS.find((c) => c.name === 'Reef');
    if (!cover) return;
    const canvas = renderCover(cover);
    src = canvas.toDataURL('image/jpeg', 0.92);
    opacity = accentFromImage(canvas).ambient;
  });
</script>

<Surface class="ambient-demo">
  <Ambient {src} {opacity} />
  <div class="content">
    <p class="t-body-strong">Reef</p>
    <p class="t-caption t-muted">accentFromImage(canvas).ambient drives the opacity of each mode.</p>
  </div>
</Surface>

<style>
  :global(.ambient-demo) {
    display: block;
    block-size: 220px;
    overflow: hidden;
    border: 1px solid var(--t-border);
    border-radius: var(--t-radius-md);
    margin-top: var(--t-space-16);
  }
  .content {
    position: relative;
    padding: var(--t-space-16);
  }
</style>
