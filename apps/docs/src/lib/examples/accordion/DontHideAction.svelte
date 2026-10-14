<!-- Don't: the main action of the screen is behind a closed header, where nobody looks for it. -->
<script lang="ts">
  import { Accordion, Button } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <Accordion.Root>
    <Accordion.Item value="more">
      <Accordion.Trigger>More options</Accordion.Trigger>
      <Accordion.Content><Button variant="primary">Place the order</Button></Accordion.Content>
    </Accordion.Item>
  </Accordion.Root>
</div>
