<script lang="ts">
  import { Field, Textarea } from '@tsuya/svelte';

  let message = $state('A textarea starts two controls tall,\ngrows with its text,\nand scrolls after maxRows lines.');
</script>

<div class="wide">
  <Field label="Message">
    {#snippet control(props)}<Textarea bind:value={message} maxRows={4} {...props} />{/snippet}
  </Field>
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
