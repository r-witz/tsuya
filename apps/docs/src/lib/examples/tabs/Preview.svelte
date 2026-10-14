<script lang="ts">
  import { Tabs } from '@tsuya/svelte';
</script>

<div style="width: min(100%, 420px)">
  <Tabs.Root>
    <Tabs.List>
      <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
      <Tabs.Trigger value="reviews">Reviews</Tabs.Trigger>
      <Tabs.Trigger value="specs">Specs</Tabs.Trigger>
    </Tabs.List>
    <Tabs.Content value="overview">A light, quiet keyboard for long days.</Tabs.Content>
    <Tabs.Content value="reviews">4.6 out of 5, from 128 reviews.</Tabs.Content>
    <Tabs.Content value="specs">Wireless, 78 keys, 40 hours of battery.</Tabs.Content>
  </Tabs.Root>
</div>
