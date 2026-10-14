<!--
  A component's props, generated from @tsuya/svelte's built types by scripts/generate-props.mjs: name,
  type, default and description. Plain tokens, no invented "table" component — DESIGN.md does not define one.
-->
<script lang="ts">
  import type { PropRow } from '#lib/content/props.ts';

  import TableScroll from './TableScroll.svelte';

  let { rows }: { rows: PropRow[] } = $props();
</script>

<TableScroll label="Props">
  <table class="props-table">
    <thead>
      <tr>
        <th>Name</th>
        <th>Type</th>
        <th>Default</th>
        <th>Description</th>
      </tr>
    </thead>
    <tbody>
      {#each rows as row (row.name)}
        <tr>
          <td><code class="t-mono">{row.name}{row.required ? '' : '?'}</code></td>
          <td><code class="t-mono">{row.type}</code></td>
          <td
            >{#if row.default}<code class="t-mono">{row.default}</code>{:else}—{/if}</td
          >
          <td>{row.description || '—'}</td>
        </tr>
      {/each}
    </tbody>
  </table>
</TableScroll>

<style>
  .props-table {
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
    vertical-align: top;
  }
  td code {
    color: var(--t-text);
  }
</style>
