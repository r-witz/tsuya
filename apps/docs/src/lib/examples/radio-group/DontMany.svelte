<!-- Don't: more than five options are a Select (DESIGN.md, Select); a long group of radios takes the whole screen. -->
<script lang="ts">
  import { Radio, RadioGroup } from '@tsuya/svelte';

  let country = $state('fr');
</script>

<RadioGroup bind:value={country} name="country" label="Country">
  <Radio value="fr">France</Radio>
  <Radio value="de">Germany</Radio>
  <Radio value="it">Italy</Radio>
  <Radio value="es">Spain</Radio>
  <Radio value="pt">Portugal</Radio>
  <Radio value="be">Belgium</Radio>
  <Radio value="nl">Netherlands</Radio>
</RadioGroup>
