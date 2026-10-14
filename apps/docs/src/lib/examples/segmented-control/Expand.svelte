<script lang="ts">
  import { SegmentedControl } from '@tsuya/svelte';

  let range = $state('week');
</script>

<div class="wide">
  <SegmentedControl
    bind:value={range}
    label="Range"
    expand
    options={[
      { value: 'day', label: 'Day' },
      { value: 'week', label: 'Week' },
      { value: 'month', label: 'Month' },
    ]}
  />
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
