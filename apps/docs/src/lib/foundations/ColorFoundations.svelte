<!--
  The colour tokens (DESIGN.md, Foundations) and their contrast, computed live by contrast() from @tsuya/core so the
  numbers can never drift from the tokens they describe. Each swatch sits on its own mode's bg, not the page's
  current mode, so light and dark are both visible at once without a toggle.
-->
<script lang="ts">
  import { dark, light } from '@tsuya/core/tokens';

  import { colorRows, contrastRows } from '#lib/content/foundations.ts';
</script>

<table class="color-table">
  <thead>
    <tr>
      <th>Token</th>
      <th>Light</th>
      <th>Dark</th>
    </tr>
  </thead>
  <tbody>
    {#each colorRows as row (row.name)}
      <tr>
        <td><code class="t-mono">{row.cssVar}</code></td>
        <td>
          <span class="stage" style:background-color={light.color.bg}>
            <span class="swatch" style:background-color={row.light}></span>
            <code class="t-mono hex" style:color={light.color.textMuted}>{row.light}</code>
          </span>
        </td>
        <td>
          <span class="stage" style:background-color={dark.color.bg}>
            <span class="swatch" style:background-color={row.dark}></span>
            <code class="t-mono hex" style:color={dark.color.textMuted}>{row.dark}</code>
          </span>
        </td>
      </tr>
    {/each}
  </tbody>
</table>

<h3 class="t-title-s">Contrast</h3>
<p class="t-body t-muted">
  A pairing of each token against the background it is normally read over, not every combination.
</p>
<table class="color-table">
  <thead>
    <tr>
      <th>Pair</th>
      <th>Light</th>
      <th>Dark</th>
    </tr>
  </thead>
  <tbody>
    {#each contrastRows as row (row.label)}
      <tr>
        <td>{row.label}</td>
        <td>{row.light.toFixed(2)}:1</td>
        <td>{row.dark.toFixed(2)}:1</td>
      </tr>
    {/each}
  </tbody>
</table>

<style>
  .color-table {
    width: 100%;
    margin-top: var(--t-space-16);
    border-collapse: collapse;
    font: var(--t-type-small);
    letter-spacing: var(--t-type-small-tracking);
  }
  th {
    padding: var(--t-space-8) var(--t-space-12);
    border-bottom: 1px solid var(--t-border-strong);
    color: var(--t-text-muted);
    font: var(--t-type-label);
    letter-spacing: var(--t-type-label-tracking);
    text-align: start;
  }
  td {
    padding: var(--t-space-12);
    border-bottom: 1px solid var(--t-border);
    vertical-align: middle;
  }
  .stage {
    display: inline-flex;
    align-items: center;
    gap: var(--t-space-8);
    padding: var(--t-space-8);
    border-radius: var(--t-radius-xs);
  }
  .swatch {
    inline-size: var(--t-size-icon-lg);
    block-size: var(--t-size-icon-lg);
    border-radius: var(--t-radius-xs);
    flex: none;
  }
  .hex {
    white-space: nowrap;
  }
</style>
