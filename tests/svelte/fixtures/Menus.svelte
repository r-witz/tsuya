<!-- A menu of actions from a button, with options and a destructive item, and one from an icon button on glass. -->
<script lang="ts">
  import { labelsEn } from '../../../packages/core/src/labels.ts';
  import { Button, IconButton, Menu, TsuyaProvider } from '../../../packages/svelte/src/lib/index.ts';

  interface Props {
    open?: boolean;
    /** The menu on glass holds a destructive item. */
    danger?: boolean;
    dir?: 'ltr' | 'rtl';
  }

  let { open = $bindable(false), danger = false, dir = 'ltr' }: Props = $props();

  let chosen = $state<string[]>([]);
  let wrap = $state(true);
  let sort = $state('name');
  const choose = (name: string) => () => {
    chosen = [...chosen, name];
  };
</script>

{#snippet pen()}<svg viewBox="0 0 24 24" data-testid="icon"><path d="M4 20l4-1 11-11-3-3L5 16z" /></svg>{/snippet}
{#snippet dots()}<svg viewBox="0 0 24 24"><path d="M5 12h.01M12 12h.01M19 12h.01" /></svg>{/snippet}

<TsuyaProvider labels={labelsEn}>
  <div {dir} style="display: flex; justify-content: space-between; padding: var(--t-space-16)">
    <Menu.Root bind:open>
      <Menu.Trigger>Actions</Menu.Trigger>
      <Menu.Content>
        <Menu.Item icon={pen} shortcut="⌘ R" onselect={choose('rename')}>Rename</Menu.Item>
        <Menu.Item onselect={choose('duplicate')}>Duplicate</Menu.Item>
        <Menu.Item disabled onselect={choose('move')}>Move</Menu.Item>
        <Menu.Separator />
        <Menu.CheckboxItem bind:checked={wrap}>Wrap lines</Menu.CheckboxItem>
        <Menu.Label>Sort by</Menu.Label>
        <Menu.RadioGroup bind:value={sort} label="Sort by">
          <Menu.RadioItem value="name">Name</Menu.RadioItem>
          <Menu.RadioItem value="date">Date</Menu.RadioItem>
        </Menu.RadioGroup>
        <Menu.Separator />
        <Menu.Item destructive onselect={choose('delete')}>Delete</Menu.Item>
      </Menu.Content>
    </Menu.Root>
    <div class="t-glass" style="padding: var(--t-space-8); border-radius: var(--t-radius-full)">
      <Menu.Root>
        <Menu.Trigger>
          {#snippet child(props)}<IconButton {...props} label="More" variant="glass" icon={dots} />{/snippet}
        </Menu.Trigger>
        <Menu.Content>
          <Menu.Item onselect={choose('share')}>Share</Menu.Item>
          <Menu.Item onselect={choose('copy')}>Copy link</Menu.Item>
          {#if danger}<Menu.Item destructive onselect={choose('remove')}>Remove</Menu.Item>{/if}
        </Menu.Content>
      </Menu.Root>
    </div>
  </div>
  <div style="display: flex; justify-content: flex-end; padding: var(--t-space-16)"><Button>After</Button></div>
  <output data-testid="chosen">{chosen.join(',')}</output>
  <output data-testid="wrap">{String(wrap)}</output>
  <output data-testid="sort">{sort}</output>
</TsuyaProvider>
