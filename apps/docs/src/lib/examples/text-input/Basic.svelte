<script lang="ts">
  import { Field, SearchInput, Textarea, TextInput } from '@tsuya/svelte';

  let { size = 'md' }: { size?: 'sm' | 'md' } = $props();

  let email = $state('');
  let notes = $state('');
  let query = $state('');
</script>

<div class="stack">
  <Field label="Email" hint="We only use it to sign you in." required>
    {#snippet control(props)}
      <TextInput bind:value={email} type="email" placeholder="you@example.com" {...props} />
    {/snippet}
  </Field>
  <Field label="Notes" optional>
    {#snippet control(props)}<Textarea bind:value={notes} {...props} />{/snippet}
  </Field>
  <SearchInput bind:value={query} label="Search the docs" placeholder="Search" {size} />
</div>

<style>
  .stack {
    display: grid;
    gap: var(--t-space-16);
    width: min(100%, 24rem);
  }
</style>
