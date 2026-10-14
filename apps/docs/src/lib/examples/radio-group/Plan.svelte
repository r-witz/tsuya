<script lang="ts">
  import { Radio, RadioGroup } from '@tsuya/svelte';

  let plan = $state('team');
</script>

<RadioGroup bind:value={plan} name="plan" label="Plan">
  <Radio value="free">Free</Radio>
  <Radio value="team">Team</Radio>
  <Radio value="enterprise" disabled>Enterprise (contact us)</Radio>
</RadioGroup>
