<script lang="ts">
  import { Field, TextInput } from '@tsuya/svelte';

  let weight = $state('72');
  let password = $state('');
  let name = $state('Ada Lovelace');
</script>

<div class="stack">
  <Field label="Weight">
    {#snippet control(props)}
      <TextInput bind:value={weight} inputmode="decimal" {...props}>
        {#snippet trailing()}kg{/snippet}
      </TextInput>
    {/snippet}
  </Field>
  <Field label="Password">
    {#snippet control(props)}<TextInput bind:value={password} type="password" {...props} />{/snippet}
  </Field>
  <Field label="Name">
    {#snippet control(props)}<TextInput bind:value={name} clearable {...props} />{/snippet}
  </Field>
</div>

<style>
  .stack {
    display: grid;
    gap: var(--t-space-16);
    width: min(100%, 24rem);
  }
</style>
