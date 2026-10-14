<script lang="ts">
  import { Field, TextInput } from '@tsuya/svelte';

  let name = $state('');
</script>

<div class="wide">
  <Field label="Full name">
    {#snippet control(props)}<TextInput bind:value={name} placeholder="Ada Lovelace" {...props} />{/snippet}
  </Field>
</div>

<style>
  .wide {
    width: 100%;
  }
</style>
