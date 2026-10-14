<!-- A panel that comes and goes with presence. -->
<script lang="ts">
  import { presence, type PresenceOptions } from '../../../packages/svelte/src/lib/primitives/presence.ts';

  let { show = false, options = {} }: { show?: boolean; options?: PresenceOptions } = $props();
</script>

{#if show}
  <div data-testid="panel" transition:presence={options}>Panel</div>
{/if}
