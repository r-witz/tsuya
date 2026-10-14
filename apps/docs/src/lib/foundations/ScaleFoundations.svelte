<!--
  Space, radius and size (DESIGN.md, "Space, radius, size"): the raw numbers, and what they look like.
-->
<script lang="ts">
  import { radiusRows, sizeRows, spaceRows } from '#lib/content/foundations.ts';
</script>

<h3 class="t-title-s">Space</h3>
<div class="bars">
  {#each spaceRows as row (row.name)}
    <div class="bar-row">
      <code class="t-mono name">{row.cssVar}</code>
      <span class="bar" style="width: {row.value}px"></span>
      <span class="t-caption t-muted">{row.value}px</span>
    </div>
  {/each}
</div>

<h3 class="t-title-s">Radius</h3>
<div class="boxes">
  {#each radiusRows as row (row.name)}
    <div class="box-col">
      <span class="box" style="border-radius: {row.value}px"></span>
      <code class="t-mono t-caption">{row.cssVar}</code>
    </div>
  {/each}
</div>

<h3 class="t-title-s">Size</h3>
<table class="scale-table">
  <thead>
    <tr>
      <th>Token</th>
      <th>Value</th>
    </tr>
  </thead>
  <tbody>
    {#each sizeRows as row (row.name)}
      <tr>
        <td><code class="t-mono">{row.cssVar}</code></td>
        <td>{row.value}px</td>
      </tr>
    {/each}
  </tbody>
</table>

<style>
  .bars {
    display: flex;
    flex-direction: column;
    gap: var(--t-space-12);
    margin-top: var(--t-space-16);
  }
  .bar-row {
    display: grid;
    grid-template-columns: 11ch 1fr 6ch;
    align-items: center;
    gap: var(--t-space-12);
  }
  .name {
    color: var(--t-text-muted);
  }
  .bar {
    block-size: var(--t-space-16);
    background: var(--t-accent);
    border-radius: var(--t-radius-xs);
  }
  .boxes {
    display: flex;
    flex-wrap: wrap;
    gap: var(--t-space-24);
    margin-top: var(--t-space-16);
  }
  .box-col {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: var(--t-space-8);
  }
  .box {
    inline-size: 56px;
    block-size: 56px;
    background: var(--t-fill-strong);
  }
  .scale-table {
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
  }
</style>
