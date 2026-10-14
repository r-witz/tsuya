<script lang="ts">
  import { PageHeader } from '@tsuya/svelte';

  import ColorFoundations from '#lib/foundations/ColorFoundations.svelte';
  import MotionFoundations from '#lib/foundations/MotionFoundations.svelte';
  import ScaleFoundations from '#lib/foundations/ScaleFoundations.svelte';
  import TypeFoundations from '#lib/foundations/TypeFoundations.svelte';
</script>

<svelte:head>
  <title>Foundations — tsuya</title>
</svelte:head>

<PageHeader title="Foundations" subtitle="The tokens every component is built from" />

<p class="t-body-l">
  Colour, type, space, radius, motion and state are plain CSS custom properties and Dart constants, generated from the
  same JSON (<code>@tsuya/core/tokens</code>). Every value below is read live from that package, not copied by hand.
</p>

<section id="foundations-color">
  <h2 class="t-title-l">Colour</h2>
  <ColorFoundations />
</section>

<section id="foundations-type">
  <h2 class="t-title-l">Type</h2>
  <p class="t-body t-muted">
    Inter (400 to 800) and Geist Mono (400). Each style is a <code>font</code> shorthand and a tracking.
  </p>
  <TypeFoundations />
</section>

<section id="foundations-scale">
  <h2 class="t-title-l">Space, radius, size</h2>
  <ScaleFoundations />
</section>

<section id="foundations-motion">
  <h2 class="t-title-l">Motion and states</h2>
  <MotionFoundations />
</section>

<section id="foundations-icons">
  <h2 class="t-title-l">Icons</h2>
  <p class="t-body">
    No icon set ships. Components take icons as snippets (Svelte) or widgets (Flutter) and size them: <code
      >--t-size-icon</code
    >
    by default, <code>--t-size-icon-sm</code> small, <code>--t-size-icon-lg</code> large; the component colours them. Docs
    and examples use Lucide (stroke 1.8, round caps and joins). tsuya draws a few glyphs itself — check, minus, chevron, close,
    search, alert, eye and eye off — for its own components. Directional glyphs mirror in right-to-left layouts.
  </p>
</section>

<section id="foundations-writing">
  <h2 class="t-title-l">Writing</h2>
  <p class="t-body">
    Labels are short verbs. Counts go in subtitles. An error says what to do next, not a code. An empty state says what
    is missing and offers one action. Write in the product's language with its typography.
  </p>
</section>

<section id="foundations-accessibility">
  <h2 class="t-title-l">Accessibility</h2>
  <p class="t-body">
    Roles, names and states for every control; an icon-only control needs a label; decorative pictures and icons are
    hidden. Overlays move focus in and back, and close on Escape. Text up to 200% clips nothing except one-line labels,
    which end with an ellipsis; up to 300% (Flutter) and 400% zoom at 320px (web) nothing overflows. Reduced motion,
    reduced transparency, high contrast and forced colours are followed. Layouts mirror in right-to-left: logical CSS
    properties, <code>Directionality</code> on Flutter; arrow keys follow the visual order.
  </p>
</section>

<style>
  section {
    margin-top: var(--t-space-48);
  }
</style>
