<!--
  The keyboard table of a component page: the keys DESIGN.md documents for it, and what each one does.
-->
<script lang="ts">
  import TableScroll from './TableScroll.svelte';

  export interface KeyRow {
    keys: string;
    action: string;
  }

  let { rows }: { rows: KeyRow[] } = $props();
</script>

<TableScroll label="Keyboard">
  <table class="keyboard-table">
    <thead>
      <tr>
        <th>Key</th>
        <th>Action</th>
      </tr>
    </thead>
    <tbody>
      {#each rows as row (row.keys)}
        <tr>
          <td><kbd class="t-mono">{row.keys}</kbd></td>
          <td>{row.action}</td>
        </tr>
      {/each}
    </tbody>
  </table>
</TableScroll>

<style>
  .keyboard-table {
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
  kbd {
    padding: 0 var(--t-space-4);
    border: 1px solid var(--t-border-strong);
    border-radius: var(--t-radius-xs);
    background: var(--t-fill);
  }
</style>
