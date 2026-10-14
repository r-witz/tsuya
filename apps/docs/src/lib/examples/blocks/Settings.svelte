<!--
  Settings: neutral glass (no content leads, so GlassScope neutral), the account row first, sections of two
  to six rows, switches that apply at once (no save button), and the destructive row alone at the end. A phone shows
  every section in one list; from 800 wide a sidebar picks the section and the column stays at 560. With about
  twenty settings or more, a search field would go above the account row; this page has twelve.
-->
<script lang="ts">
  import {
    Avatar,
    Button,
    Dialog,
    GlassScope,
    List,
    ListItem,
    PageHeader,
    Screen,
    Section,
    Sidebar,
    SidebarGroup,
    SidebarItem,
    Slider,
    Switch,
    TabBar,
    type TabBarItem,
  } from '@tsuya/svelte';

  import BlockIcon from '#lib/icons/BlockIcon.svelte';

  let width = $state(0);
  let section = $state('notifications');
  let tab = $state('settings');
  let deleting = $state(false);
  // every switch applies the moment it moves: this is the whole "save" of the page
  let on = $state({
    push: true,
    digest: false,
    sound: true,
    transparency: false,
    motion: false,
    activity: true,
    analytics: false,
  });
  let textSize = $state(100);

  const wide = $derived(width >= 800);
  const SECTIONS = [
    { id: 'notifications', label: 'Notifications' },
    { id: 'appearance', label: 'Appearance' },
    { id: 'privacy', label: 'Privacy' },
  ];
  const TABS: TabBarItem[] = [
    { value: 'library', label: 'Library', icon: library },
    { value: 'search', label: 'Search', icon: search },
    { value: 'settings', label: 'Settings', icon: cog },
  ];
  // a section is shown on a phone, and when it is the one the sidebar picked
  const shows = (id: string) => !wide || section === id;
</script>

{#snippet library()}<BlockIcon name="library" />{/snippet}
{#snippet search()}<BlockIcon name="search" />{/snippet}
{#snippet cog()}<BlockIcon name="settings" />{/snippet}
{#snippet dock()}<TabBar bind:value={tab} items={TABS} aria-label="Sections" />{/snippet}

<GlassScope neutral>
  <Screen dock={wide ? undefined : dock}>
    <div class="shell" class:wide bind:clientWidth={width}>
      {#if wide}
        <Sidebar aria-label="Settings sections">
          <SidebarGroup label="Settings">
            {#each SECTIONS as { id, label } (id)}
              <SidebarItem current={section === id} onclick={() => (section = id)}>{label}</SidebarItem>
            {/each}
          </SidebarGroup>
        </Sidebar>
      {/if}

      <div class="column">
        <PageHeader title="Settings" />

        <List>
          <!-- the account row comes first, a little taller than the others; the app opens the account page from it -->
          <ListItem tall title="Nora Vale" subtitle="nora@example.com" onclick={() => {}}>
            {#snippet leading()}<Avatar initials="NV" size={48} label="Nora Vale" />{/snippet}
          </ListItem>
        </List>

        {#if shows('notifications')}
          <Section label="Notifications">
            <ListItem title="Push notifications">
              {#snippet trailing()}<Switch bind:checked={on.push} />{/snippet}
            </ListItem>
            <ListItem title="Weekly digest" subtitle="One email on Monday morning">
              {#snippet trailing()}<Switch bind:checked={on.digest} />{/snippet}
            </ListItem>
            <ListItem title="Sounds">
              {#snippet trailing()}<Switch bind:checked={on.sound} />{/snippet}
            </ListItem>
          </Section>
        {/if}

        {#if shows('appearance')}
          <Section label="Appearance">
            <ListItem title="Reduce transparency">
              {#snippet trailing()}<Switch bind:checked={on.transparency} />{/snippet}
            </ListItem>
            <ListItem title="Reduce motion">
              {#snippet trailing()}<Switch bind:checked={on.motion} />{/snippet}
            </ListItem>
            <ListItem title="Text size">
              {#snippet trailing()}
                <span class="slider">
                  <Slider
                    label="Text size"
                    min={80}
                    max={140}
                    step={10}
                    bind:value={textSize}
                    valueLabel={(v) => `${String(v)} %`}
                  />
                </span>
                <span class="value t-small t-tabular">{textSize} %</span>
              {/snippet}
            </ListItem>
          </Section>
        {/if}

        {#if shows('privacy')}
          <Section label="Privacy">
            <ListItem title="Show what I am listening to">
              {#snippet trailing()}<Switch bind:checked={on.activity} />{/snippet}
            </ListItem>
            <ListItem title="Share usage data" subtitle="Anonymous, to fix what is broken">
              {#snippet trailing()}<Switch bind:checked={on.analytics} />{/snippet}
            </ListItem>
            <ListItem title="Download my data" onclick={() => {}}>
              {#snippet trailing()}<span class="icon"><BlockIcon name="download" /></span>{/snippet}
            </ListItem>
          </Section>
        {/if}

        <!-- a destructive row stands alone, in the last group, and asks before it does anything -->
        <Dialog.Root bind:open={deleting}>
          <div class="danger">
            <List>
              <ListItem destructive title="Delete account" onclick={() => (deleting = true)} />
            </List>
          </div>
          <Dialog.Content>
            <Dialog.Title>Delete your account?</Dialog.Title>
            <Dialog.Description
              >Your library and your playlists are deleted for good. This cannot be undone.</Dialog.Description
            >
            <Dialog.Actions>
              <Dialog.Close>
                {#snippet children(props)}<Button {...props} variant="secondary" autofocus>Keep my account</Button
                  >{/snippet}
              </Dialog.Close>
              <Button variant="danger" onclick={() => (deleting = false)}>Delete my account</Button>
            </Dialog.Actions>
          </Dialog.Content>
        </Dialog.Root>
      </div>
    </div>
  </Screen>
</GlassScope>

<style>
  .shell {
    display: flex;
    gap: var(--t-space-24);
    max-width: 1200px;
    margin-inline: auto;
    padding-top: var(--t-space-24);
  }
  .column {
    display: flex;
    flex: 1;
    flex-direction: column;
    gap: var(--t-space-8);
    min-width: 0;
  }
  /* the column stays at 560 beside the sidebar */
  .wide .column {
    flex: 0 1 560px;
  }
  .slider {
    width: 140px;
  }
  .value,
  .icon {
    color: var(--t-text-muted);
  }
  .value {
    min-width: var(--t-space-48);
    text-align: end;
  }
  .icon {
    display: flex;
  }
  .danger {
    margin-top: var(--t-space-24);
  }
</style>
