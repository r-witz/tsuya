<script lang="ts">
  import { Field, TextInput } from '@tsuya/svelte';

  let email = $state('ada@');
  let locked = $state('ada@example.com');
</script>

<div class="stack">
  <Field label="Email" error="Enter an address like name@example.com.">
    {#snippet control(props)}<TextInput bind:value={email} type="email" {...props} />{/snippet}
  </Field>
  <Field label="Account email">
    {#snippet control(props)}<TextInput bind:value={locked} disabled {...props} />{/snippet}
  </Field>
</div>

<style>
  .stack {
    display: grid;
    gap: var(--t-space-16);
    width: min(100%, 24rem);
  }
</style>
