<script lang="ts">
  import { Field } from '@tsuya/svelte';
</script>

<div class="wide">
  <Field label="Start date" hint="The first day of the trial.">
    {#snippet control(props)}<input type="date" {...props} />{/snippet}
  </Field>
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
