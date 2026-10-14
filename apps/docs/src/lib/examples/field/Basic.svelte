<script lang="ts">
  import { Field, TextInput } from '@tsuya/svelte';

  let name = $state('');
</script>

<div class="wide">
  <Field label="Display name" hint="Shown to the other members of your team.">
    {#snippet control(props)}<TextInput bind:value={name} {...props} />{/snippet}
  </Field>
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
