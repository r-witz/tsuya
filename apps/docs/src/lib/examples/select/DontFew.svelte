<!-- Don't: two options seen together are a SegmentedControl or a Switch; a Select hides them behind a press. -->
<script lang="ts">
  import { Select } from '@tsuya/svelte';

  let theme = $state('light');
</script>

<div class="wide">
  <Select
    bind:value={theme}
    label="Theme"
    options={[
      { value: 'light', label: 'Light' },
      { value: 'dark', label: 'Dark' },
    ]}
  />
</div>

<style>
  .wide {
    width: 100%;
  }
</style>
