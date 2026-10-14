<script lang="ts">
  import { Checkbox } from '@tsuya/svelte';

  let remember = $state(true);
</script>

<Checkbox bind:checked={remember}>Remember me</Checkbox>
