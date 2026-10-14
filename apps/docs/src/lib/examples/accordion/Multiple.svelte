<script lang="ts">
  import { Accordion } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <Accordion.Root type="multiple" value={['sizes', 'care']}>
    <Accordion.Item value="sizes">
      <Accordion.Trigger>Sizes</Accordion.Trigger>
      <Accordion.Content>XS to XL, true to size.</Accordion.Content>
    </Accordion.Item>
    <Accordion.Item value="care">
      <Accordion.Trigger>Care</Accordion.Trigger>
      <Accordion.Content>Machine wash, cold.</Accordion.Content>
    </Accordion.Item>
  </Accordion.Root>
</div>
