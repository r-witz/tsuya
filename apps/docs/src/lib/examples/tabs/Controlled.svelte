<script lang="ts">
  import { Tabs } from '@tsuya/svelte';

  let value = $state('reviews');
</script>

<div style="width: 100%">
  <Tabs.Root bind:value>
    <Tabs.List>
      <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
      <Tabs.Trigger value="reviews">Reviews</Tabs.Trigger>
      <Tabs.Trigger value="specs" disabled>Specs</Tabs.Trigger>
    </Tabs.List>
    <Tabs.Content value="overview">A light, quiet keyboard for long days.</Tabs.Content>
    <Tabs.Content value="reviews">4.6 out of 5, from 128 reviews.</Tabs.Content>
    <Tabs.Content value="specs">Wireless, 78 keys, 40 hours of battery.</Tabs.Content>
  </Tabs.Root>
  <p>Selected: {value}</p>
</div>
