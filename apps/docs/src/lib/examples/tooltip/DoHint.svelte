<script lang="ts">
  import { Field, TextInput } from '@tsuya/svelte';

  let password = $state('');
</script>

<div class="wide">
  <Field label="Password" hint="At least 12 characters, with one number.">
    {#snippet control(props)}<TextInput bind:value={password} type="password" {...props} />{/snippet}
  </Field>
</div>

<style>
  .wide {
    width: 100%;
  }
</style>
