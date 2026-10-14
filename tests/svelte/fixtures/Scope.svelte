<!-- A modal opened by a button: a focus scope, with a second one that opens over it. -->
<script lang="ts">
  import { focusScope, type FocusScopeOptions } from '../../../packages/core/src/primitives/focus.ts';

  interface Props {
    options?: FocusScopeOptions;
    mark?: boolean;
    empty?: boolean;
  }

  let { options = {}, mark = false, empty = false }: Props = $props();
  let open = $state(false);
  let inner = $state(false);
</script>

<button type="button" onclick={() => (open = true)}>Open</button>
{#if open}
  <div role="dialog" aria-label="Scope" data-testid="scope" {@attach focusScope(options)}>
    {#if !empty}
      <button type="button" disabled>Disabled</button>
      <input aria-label="Name" />
      <input type="radio" name="size" aria-label="Small" />
      <input type="radio" name="size" aria-label="Large" checked />
      <button type="button" hidden>Hidden</button>
      <button type="button" data-autofocus={mark || undefined} onclick={() => (inner = true)}>Inner</button>
      <button type="button" onclick={() => (open = false)}>Close</button>
    {/if}
    {#if inner}
      <div role="dialog" aria-label="Inner scope" {@attach focusScope()}>
        <button type="button" onclick={() => (inner = false)}>Back</button>
        <button type="button">Other</button>
      </div>
    {/if}
  </div>
{/if}
<button type="button">Page</button>
