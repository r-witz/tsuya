<script lang="ts">
  import { IconButton, SearchInput, TopBar } from '@tsuya/svelte';

  import NavIcon from '#lib/icons/NavIcon.svelte';
</script>

<div class="art">
  <TopBar>
    {#snippet start()}<strong>tsuya</strong>{/snippet}
    {#snippet center()}<SearchInput label="Search the docs" size="sm" />{/snippet}
    {#snippet end()}
      <IconButton label="Notifications" variant="plain">
        {#snippet icon()}<NavIcon name="bell" />{/snippet}
      </IconButton>
    {/snippet}
  </TopBar>
</div>

<style>
  .art {
    display: flex;
    flex-direction: column;
    width: 100%;
    min-height: 168px;
    padding-bottom: var(--t-space-16);
    border-radius: var(--t-radius-md);
    background: linear-gradient(135deg, #1fb8a6, #0c2b3a);
  }
</style>
