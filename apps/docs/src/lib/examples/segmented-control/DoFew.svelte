<script lang="ts">
  import { SegmentedControl } from '@tsuya/svelte';

  let range = $state('week');
</script>

<SegmentedControl
  bind:value={range}
  label="Range"
  options={[
    { value: 'day', label: 'Day' },
    { value: 'week', label: 'Week' },
    { value: 'month', label: 'Month' },
  ]}
/>
