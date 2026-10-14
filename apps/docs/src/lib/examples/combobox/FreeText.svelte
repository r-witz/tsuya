<script lang="ts">
  import { Combobox } from '@tsuya/svelte';

  let inputValue = $state('');
</script>

<div class="wide">
  <Combobox
    bind:inputValue
    label="Assignee"
    hint="Pick someone, or type an email address."
    freeText
    options={[
      { value: 'ada', label: 'Ada Lovelace' },
      { value: 'alan', label: 'Alan Turing' },
      { value: 'grace', label: 'Grace Hopper' },
    ]}
  />
</div>

<style>
  .wide {
    width: min(100%, 24rem);
  }
</style>
