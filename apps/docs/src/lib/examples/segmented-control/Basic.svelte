<script lang="ts">
  import { SegmentedControl } from '@tsuya/svelte';

  let view = $state('list');
</script>

<SegmentedControl
  bind:value={view}
  label="View"
  options={[
    { value: 'list', label: 'List' },
    { value: 'grid', label: 'Grid' },
    { value: 'map', label: 'Map' },
  ]}
/>
