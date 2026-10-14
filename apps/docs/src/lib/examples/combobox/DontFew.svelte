<!-- Don't: three fixed options need no typing; a Select, or radios, shows them without a keyboard. -->
<script lang="ts">
  import { Combobox } from '@tsuya/svelte';

  let size = $state<string>();
</script>

<div class="wide">
  <Combobox
    bind:value={size}
    label="Size"
    options={[
      { value: 's', label: 'Small' },
      { value: 'm', label: 'Medium' },
      { value: 'l', label: 'Large' },
    ]}
  />
</div>

<style>
  .wide {
    width: 100%;
  }
</style>
