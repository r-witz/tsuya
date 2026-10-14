<!-- Don't: the placeholder is not a label; it disappears as soon as the user types (DESIGN.md, Field). -->
<script lang="ts">
  import { TextInput } from '@tsuya/svelte';

  let name = $state('');
</script>

<div class="wide">
  <TextInput bind:value={name} placeholder="Full name" aria-label="Full name" />
</div>

<style>
  .wide {
    width: 100%;
  }
</style>
