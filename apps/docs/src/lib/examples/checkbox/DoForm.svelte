<script lang="ts">
  import { Button, Checkbox } from '@tsuya/svelte';

  let newsletter = $state(true);
</script>

<form
  onsubmit={(event) => {
    event.preventDefault();
  }}
>
  <Checkbox bind:checked={newsletter} name="newsletter">Send me the newsletter</Checkbox>
  <Button variant="primary" type="submit">Create account</Button>
</form>

<style>
  form {
    display: grid;
    gap: var(--t-space-8);
    justify-items: start;
  }
</style>
