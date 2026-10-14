<script lang="ts">
  import { accentFromColor } from '@tsuya/core';
  import { PageHeader } from '@tsuya/svelte';

  import AccentPlayground from '#lib/material/AccentPlayground.svelte';
  import AmbientDemo from '#lib/material/AmbientDemo.svelte';
  import FallbacksDemo from '#lib/material/FallbacksDemo.svelte';
  import GlassDemo from '#lib/material/GlassDemo.svelte';
  import GrainDemo from '#lib/material/GrainDemo.svelte';

  let seed = $state('#1fb8a6');
  const pair = $derived(accentFromColor(seed));
</script>

<svelte:head>
  <title>Material — tsuya</title>
</svelte:head>

<PageHeader title="Material" subtitle="The engine, the ambient background, glass and grain" />

<p class="t-body-l">
  The content leads: its colour becomes the accent, its image lights the background. The same engine runs on Svelte and
  Flutter, bit-identical.
</p>

<section id="material-accent">
  <h2 class="t-title-l">Accent</h2>
  <p class="t-body t-muted">
    Pick a seed: <code>accentFromColor</code> clamps its lightness into each mode's band, keeps its hue, and turns it away
    from the four statuses.
  </p>
  <AccentPlayground bind:seed />
</section>

<section id="material-ambient">
  <h2 class="t-title-l">Ambient background</h2>
  <p class="t-body t-muted">
    The leading content's image, scaled, blurred and saturated, at an opacity computed so the text on it stays readable.
  </p>
  <AmbientDemo />
</section>

<section id="material-glass">
  <h2 class="t-title-l">Glass</h2>
  <p class="t-body t-muted">
    Tinted by the accent above, or neutral. Always over content, never on a flat background; at most three layers on
    screen.
  </p>
  <GlassDemo {pair} />
</section>

<section id="material-grain">
  <h2 class="t-title-l">Grain</h2>
  <p class="t-body t-muted">A greyscale noise texture under the content, in overlay blend, never on text or glass.</p>
  <GrainDemo />
</section>

<section id="material-fallbacks">
  <h2 class="t-title-l">Fallbacks</h2>
  <FallbacksDemo />
</section>

<style>
  section {
    margin-top: var(--t-space-48);
  }
</style>
