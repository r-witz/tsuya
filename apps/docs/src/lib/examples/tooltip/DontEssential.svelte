<!-- Don't: a rule people need before they type is not for a tooltip, which touch screens never show. -->
<script lang="ts">
  import { Field, IconButton, TextInput } from '@tsuya/svelte';

  let password = $state('');
</script>

<div class="row">
  <Field label="Password" class="grow">
    {#snippet control(props)}<TextInput bind:value={password} type="password" {...props} />{/snippet}
  </Field>
  <IconButton label="At least 12 characters, with one number" variant="plain">
    {#snippet icon()}
      <svg
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        stroke-width="1.8"
        stroke-linecap="round"
        aria-hidden="true"
      >
        <circle cx="12" cy="12" r="9" />
        <path d="M12 16v-4M12 8h.01" />
      </svg>
    {/snippet}
  </IconButton>
</div>

<style>
  .row {
    display: flex;
    align-items: end;
    gap: var(--t-space-8);
    width: 100%;
  }
  .row :global(.grow) {
    flex: 1;
  }
</style>
