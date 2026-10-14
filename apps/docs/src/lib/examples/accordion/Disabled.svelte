<script lang="ts">
  import { Accordion } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <Accordion.Root>
    <Accordion.Item value="shipping">
      <Accordion.Trigger>Shipping</Accordion.Trigger>
      <Accordion.Content>Free over 50 €, 3 to 5 days.</Accordion.Content>
    </Accordion.Item>
    <Accordion.Item value="gift" disabled>
      <Accordion.Trigger>Gift wrapping</Accordion.Trigger>
      <Accordion.Content>Not available for this order.</Accordion.Content>
    </Accordion.Item>
  </Accordion.Root>
</div>
