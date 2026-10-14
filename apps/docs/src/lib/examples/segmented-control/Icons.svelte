<script lang="ts">
  import { SegmentedControl } from '@tsuya/svelte';

  let view = $state('list');
</script>

{#snippet list()}
  <svg
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="1.8"
    stroke-linecap="round"
    aria-hidden="true"
  >
    <path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01" />
  </svg>
{/snippet}
{#snippet grid()}
  <svg
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="1.8"
    stroke-linejoin="round"
    aria-hidden="true"
  >
    <path d="M4 4h7v7H4ZM13 4h7v7h-7ZM4 13h7v7H4ZM13 13h7v7h-7Z" />
  </svg>
{/snippet}

<!-- An option with an icon shows the icon alone; its label still names the segment. -->
<SegmentedControl
  bind:value={view}
  label="View"
  options={[
    { value: 'list', label: 'List', icon: list },
    { value: 'grid', label: 'Grid', icon: grid },
  ]}
/>
