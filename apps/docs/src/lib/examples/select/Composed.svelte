<script lang="ts">
  import { Field, Select } from '@tsuya/svelte';

  let role = $state('editor');
</script>

<div class="wide">
  <Select.Root bind:value={role} name="role" label="Role">
    <Field label="Role">
      {#snippet control(props)}<Select.Trigger {...props} />{/snippet}
    </Field>
    <Select.Content>
      <Select.Item value="viewer" label="Viewer" />
      <Select.Item value="editor" label="Editor" />
      <Select.Separator />
      <Select.Group label="Danger zone">
        <Select.Item value="owner" label="Owner" />
      </Select.Group>
    </Select.Content>
  </Select.Root>
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
