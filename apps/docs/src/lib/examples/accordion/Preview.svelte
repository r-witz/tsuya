<script lang="ts">
  import { Accordion } from '@tsuya/svelte';
</script>

<div style="width: min(100%, 420px)">
  <Accordion.Root>
    <Accordion.Item value="shipping">
      <Accordion.Trigger>Shipping</Accordion.Trigger>
      <Accordion.Content>Free over 50 €, 3 to 5 days.</Accordion.Content>
    </Accordion.Item>
    <Accordion.Item value="returns">
      <Accordion.Trigger>Returns</Accordion.Trigger>
      <Accordion.Content>Within 30 days, unused.</Accordion.Content>
    </Accordion.Item>
    <Accordion.Item value="warranty">
      <Accordion.Trigger>Warranty</Accordion.Trigger>
      <Accordion.Content>Two years, parts and labour.</Accordion.Content>
    </Accordion.Item>
  </Accordion.Root>
</div>
