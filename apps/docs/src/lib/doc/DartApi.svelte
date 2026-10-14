<!--
  The Flutter API of a component's public types, read from scripts/dart_api's committed output: per type,
  the parameters of each constructor, the static methods, or the values of an enum. Same look as
  PropsTable.
-->
<script lang="ts">
  import { constructorLabel, dartType } from '#lib/content/dart-api.ts';

  import TableScroll from './TableScroll.svelte';

  let { types }: { types: string[] } = $props();

  const entries = $derived(types.map((name) => ({ name, type: dartType(name) })));
</script>

{#each entries as { name, type } (name)}
  <h3 class="t-title-s">{name}</h3>
  <p class="t-body t-muted">{type.description}</p>
  {#each type.constructors ?? [] as ctor (ctor.name)}
    {#if ctor.params.length}
      <p class="t-small t-muted caption">
        <code class="t-mono">{constructorLabel(name, ctor)}(…)</code>{ctor.description ? ` — ${ctor.description}` : ''}
      </p>
      <TableScroll label="Dart API">
        <table class="dart-table">
          <thead>
            <tr><th>Name</th><th>Type</th><th>Default</th><th>Description</th></tr>
          </thead>
          <tbody>
            {#each ctor.params as param (param.name)}
              <tr>
                <td><code class="t-mono">{param.name}{param.required ? '' : '?'}</code></td>
                <td><code class="t-mono">{param.type}</code></td>
                <td
                  >{#if param.default}<code class="t-mono">{param.default}</code>{:else}—{/if}</td
                >
                <td>{param.description || '—'}</td>
              </tr>
            {/each}
          </tbody>
        </table>
      </TableScroll>
    {/if}
  {/each}
  {#if type.statics?.length}
    <TableScroll label="Dart API">
      <table class="dart-table">
        <thead>
          <tr><th>Static</th><th>Signature</th><th>Description</th></tr>
        </thead>
        <tbody>
          {#each type.statics as method (method.name)}
            <tr>
              <td><code class="t-mono">{name}.{method.name}</code></td>
              <td><code class="t-mono">{method.signature}</code></td>
              <td>{method.description || '—'}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </TableScroll>
  {/if}
  {#if type.values?.length}
    <TableScroll label="Dart API">
      <table class="dart-table">
        <thead>
          <tr><th>Value</th><th>Description</th></tr>
        </thead>
        <tbody>
          {#each type.values as value (value.name)}
            <tr>
              <td><code class="t-mono">{name}.{value.name}</code></td>
              <td>{value.description || '—'}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </TableScroll>
  {/if}
{/each}

<style>
  .caption {
    margin-top: var(--t-space-16);
  }
  .dart-table {
    width: 100%;
    margin-top: var(--t-space-8);
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
