<!--
  checkTheme live (DESIGN.md, Theming: "Neutral colours may be overridden, but then the app owns its contrast"): the
  real light tokens, with light.color.bg overridable, run through every check of the build. Starts passing; pick a
  background that is too close to the text colour to see it fail.
-->
<script lang="ts">
  import { checkTheme } from '@tsuya/core';
  import { dark, glass, light } from '@tsuya/core/tokens';

  let bg = $state(light.color.bg);

  const failures = $derived(checkTheme({ light: { ...light, color: { ...light.color, bg } }, dark, glass }));
</script>

<label class="picker t-body">
  Light mode's bg
  <input type="color" defaultValue={bg} oninput={(event) => (bg = event.currentTarget.value)} />
  <code class="t-mono">{bg}</code>
</label>

{#if failures.length === 0}
  <p class="t-body ok">Passes every check.</p>
{:else}
  <table class="fail-table">
    <thead>
      <tr>
        <th>Mode</th>
        <th>Check</th>
        <th>Ratio</th>
        <th>Needs</th>
        <th>Worst case</th>
      </tr>
    </thead>
    <tbody>
      {#each failures as f, i (i)}
        <tr>
          <td>{f.mode}</td>
          <td>{f.check}</td>
          <td>{f.ratio.toFixed(2)}:1</td>
          <td>{f.min}:1</td>
          <td>{f.worst || '—'}</td>
        </tr>
      {/each}
    </tbody>
  </table>
{/if}

<style>
  .picker {
    display: inline-flex;
    align-items: center;
    gap: var(--t-space-8);
    margin-top: var(--t-space-16);
  }
  .ok {
    margin-top: var(--t-space-16);
    color: var(--t-success);
  }
  .fail-table {
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
