<!-- A few checkboxes: plain, indeterminate, and one in a form with name and value. -->
<script lang="ts">
  import { Checkbox, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';
  import { labelsEn } from '../../../packages/core/src/labels.ts';

  interface Props {
    checked?: boolean;
    indeterminate?: boolean;
    disabled?: boolean;
  }

  let { checked = $bindable(false), indeterminate = false, disabled = false }: Props = $props();
</script>

<TsuyaProvider labels={labelsEn}>
  <div style="padding: var(--t-space-16)">
    <Checkbox bind:checked {indeterminate} {disabled} name="remember" value="yes">Remember me</Checkbox>
  </div>
</TsuyaProvider>
