<script lang="ts">
  import { Accordion } from '@tsuya/svelte';

  let value = $state(['shipping']);
</script>

<div style="width: 100%">
  <Accordion.Root bind:value>
    <Accordion.Item value="shipping">
      <Accordion.Trigger>Shipping</Accordion.Trigger>
      <Accordion.Content>Free over 50 €, 3 to 5 days.</Accordion.Content>
    </Accordion.Item>
    <Accordion.Item value="returns">
      <Accordion.Trigger>Returns</Accordion.Trigger>
      <Accordion.Content>Within 30 days, unused.</Accordion.Content>
    </Accordion.Item>
  </Accordion.Root>
</div>
