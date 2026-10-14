<script lang="ts">
  import { PageHeader } from '@tsuya/svelte';

  import BrandDemo from '#lib/theming/BrandDemo.svelte';
  import CheckThemeDemo from '#lib/theming/CheckThemeDemo.svelte';
  import FontsRadiiDemo from '#lib/theming/FontsRadiiDemo.svelte';
</script>

<svelte:head>
  <title>Theming — tsuya</title>
</svelte:head>

<PageHeader title="Theming" subtitle="Brand, fonts, radii, and owning your own contrast" />

<p class="t-body-l">Three knobs for an app to make tsuya its own, and one check that keeps it honest.</p>

<section id="theming-brand">
  <h2 class="t-title-l">Brand</h2>
  <p class="t-body t-muted">
    <code>accentFromColor(brand)</code> gives the pair; set it on the root region. It replaces the neutral accent where no
    content leads.
  </p>
  <BrandDemo />
</section>

<section id="theming-fonts-radii">
  <h2 class="t-title-l">Fonts and radii</h2>
  <p class="t-body t-muted">
    <code>--t-font-sans</code> and <code>--t-radius-xs</code> to <code>--t-radius-lg</code> may be overridden on the
    web; Flutter takes the typeface only, <code>TsuyaTheme(typeface:)</code>.
  </p>
  <FontsRadiiDemo />
</section>

<section id="theming-check">
  <h2 class="t-title-l">Owning your own contrast</h2>
  <p class="t-body t-muted">
    Neutral colours may be overridden too, but then the app owns their contrast: <code>checkTheme(theme)</code> runs every
    check of the build on a theme and returns the failures.
  </p>
  <CheckThemeDemo />
</section>

<style>
  section {
    margin-top: var(--t-space-48);
  }
</style>
