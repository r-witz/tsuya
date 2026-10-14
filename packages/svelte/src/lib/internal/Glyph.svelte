<!--
  @component
  The few glyphs tsuya draws itself (DESIGN.md, Icons), at --t-size-icon unless the component sizes it, in the current
  colour, hidden from assistive technology. Directional glyphs mirror right to left.
-->
<script lang="ts" module>
  // 24 × 24, stroked: [paths, circles as cx cy r]
  const GLYPHS = {
    check: [['M5 12.5l4.5 4.5L19 7.5'], []],
    minus: [['M6 12h12'], []],
    'chevron-down': [['M6 9l6 6 6-6'], []],
    'chevron-right': [['M9 6l6 6-6 6'], []],
    back: [['M15 6l-6 6 6 6'], []],
    close: [['M6 6l12 12M18 6L6 18'], []],
    menu: [['M4 7h16M4 12h16M4 17h16'], []],
    search: [['M20 20l-4.2-4.2'], [[11, 11, 7]]],
    alert: [['M12 7.5v5M12 16.5v.01'], [[12, 12, 9]]],
    info: [['M12 7.49v.01M12 11v5.5'], [[12, 12, 9]]],
    eye: [['M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z'], [[12, 12, 3]]],
    'eye-off': [['M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12zM4 4l16 16'], [[12, 12, 3]]],
  } as const;

  export type GlyphName = keyof typeof GLYPHS;
</script>

<script lang="ts">
  let { name }: { name: GlyphName } = $props();
  const [paths, circles] = $derived(GLYPHS[name]);
</script>

<svg
  class="t-glyph"
  class:t-glyph-mirror={name === 'chevron-right' || name === 'back'}
  viewBox="0 0 24 24"
  fill="none"
  stroke="currentColor"
  stroke-width="1.8"
  stroke-linecap="round"
  stroke-linejoin="round"
  aria-hidden="true"
  focusable="false"
>
  {#each paths as d (d)}<path {d} />{/each}
  {#each circles as [cx, cy, r] (`${String(cx)} ${String(cy)}`)}<circle {cx} {cy} {r} />{/each}
</svg>
