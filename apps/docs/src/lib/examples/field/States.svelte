<script lang="ts">
  import { Field, TextInput } from '@tsuya/svelte';

  let email = $state('');
  let phone = $state('');
  let code = $state('ABC');
</script>

<div class="stack">
  <Field label="Email" required>
    {#snippet control(props)}<TextInput bind:value={email} type="email" {...props} />{/snippet}
  </Field>
  <Field label="Phone" optional>
    {#snippet control(props)}<TextInput bind:value={phone} type="tel" {...props} />{/snippet}
  </Field>
  <Field label="Invite code" error="Codes have 6 characters. This one has 3.">
    {#snippet control(props)}<TextInput bind:value={code} {...props} />{/snippet}
  </Field>
</div>

<style>
  .stack {
    display: grid;
    gap: var(--t-space-16);
    width: min(100%, 24rem);
  }
</style>
