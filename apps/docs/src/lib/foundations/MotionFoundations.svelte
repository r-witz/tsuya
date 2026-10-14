<!--
  Motion and states (DESIGN.md, "Motion", "States"): the duration, easing and state numbers, plus what they are for.
-->
<script lang="ts">
  import { durationRows, easingRows, stateRows } from '#lib/content/foundations.ts';
</script>

<h3 class="t-title-s">Durations and easings</h3>
<p class="t-body t-muted">
  Motion accompanies a change; nothing decorative loops. Animate opacity and transforms only. Reduced motion makes every
  change instant — nothing slides, scales or springs — except loading indicators, because their motion is the
  information.
</p>
<table class="motion-table">
  <thead>
    <tr>
      <th>Token</th>
      <th>Value</th>
      <th>Used for</th>
    </tr>
  </thead>
  <tbody>
    {#each durationRows as row (row.name)}
      <tr>
        <td><code class="t-mono">{row.cssVar}</code></td>
        <td>{row.ms}ms</td>
        <td>{row.use}</td>
      </tr>
    {/each}
    {#each easingRows as row (row.name)}
      <tr>
        <td><code class="t-mono">{row.cssVar}</code></td>
        <td><code class="t-mono">{row.curve}</code></td>
        <td>{row.use}</td>
      </tr>
    {/each}
  </tbody>
</table>

<h3 class="t-title-s">States</h3>
<p class="t-body t-muted">
  Pressed, hover and focus are shown throughout the component pages. Current and selected always carry a second signal
  besides colour — weight, fill, tick or marker — never colour alone.
</p>
<table class="motion-table">
  <thead>
    <tr>
      <th>Token</th>
      <th>Value</th>
    </tr>
  </thead>
  <tbody>
    {#each stateRows as row (row.name)}
      <tr>
        <td><code class="t-mono">{row.cssVar}</code></td>
        <td>{row.value}</td>
      </tr>
    {/each}
  </tbody>
</table>

<style>
  .motion-table {
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
