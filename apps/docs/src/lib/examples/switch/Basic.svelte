<script lang="ts">
  import { Switch } from '@tsuya/svelte';

  let checked = $state(true);
</script>

<Switch label="Wi-Fi" bind:checked />
