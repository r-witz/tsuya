<script lang="ts">
  import { Tabs } from '@tsuya/svelte';
</script>

<div style="width: 100%">
  <Tabs.Root manual>
    <Tabs.List>
      <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
      <Tabs.Trigger value="reviews">Reviews</Tabs.Trigger>
    </Tabs.List>
    <Tabs.Content value="overview">Arrows move focus; Enter or Space selects.</Tabs.Content>
    <Tabs.Content value="reviews">4.6 out of 5, from 128 reviews.</Tabs.Content>
  </Tabs.Root>
</div>
