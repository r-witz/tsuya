<!-- Don't: more than five segments do not fit and are hard to scan; use a Select, or Tabs. -->
<script lang="ts">
  import { SegmentedControl } from '@tsuya/svelte';

  let month = $state('jan');
</script>

<SegmentedControl
  bind:value={month}
  label="Month"
  options={[
    { value: 'jan', label: 'Jan' },
    { value: 'feb', label: 'Feb' },
    { value: 'mar', label: 'Mar' },
    { value: 'apr', label: 'Apr' },
    { value: 'may', label: 'May' },
    { value: 'jun', label: 'Jun' },
    { value: 'jul', label: 'Jul' },
  ]}
/>
