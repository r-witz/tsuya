<script lang="ts">
  import { PageHeader } from '@tsuya/svelte';

  import { code } from '#lib/doc/code.ts';
  import CodeBlock from '#lib/doc/CodeBlock.svelte';
  import GalleryShot from '#lib/doc/GalleryShot.svelte';
  import DartApi from '#lib/doc/DartApi.svelte';
  import DoDont from '#lib/doc/DoDont.svelte';
  import Example from '#lib/doc/Example.svelte';
  import KeyboardTable from '#lib/doc/KeyboardTable.svelte';
  import PreviewStage from '#lib/doc/PreviewStage.svelte';
  import PropsTable from '#lib/doc/PropsTable.svelte';

  import MenuBasic from '#lib/examples/menu/Basic.svelte';
  import MenuDoDestructiveLast from '#lib/examples/menu/DoDestructiveLast.svelte';
  import MenuDontMixed from '#lib/examples/menu/DontMixed.svelte';
  import MenuFull from '#lib/examples/menu/Full.svelte';

  import rootProps from '../../../../.generated/props/menu-root.json' with { type: 'json' };
  import triggerProps from '../../../../.generated/props/menu-trigger.json' with { type: 'json' };
  import contentProps from '../../../../.generated/props/menu-content.json' with { type: 'json' };
  import itemProps from '../../../../.generated/props/menu-item.json' with { type: 'json' };
  import checkboxItemProps from '../../../../.generated/props/menu-checkbox-item.json' with { type: 'json' };
  import radioGroupProps from '../../../../.generated/props/menu-radio-group.json' with { type: 'json' };
  import radioItemProps from '../../../../.generated/props/menu-radio-item.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Menu — tsuya</title>
</svelte:head>

<PageHeader title="Menu" subtitle="Overlays and feedback" />

<p class="t-body-l">
  Actions anchored to the control that opens them. Composed from parts — <code>Menu.Root</code>,
  <code>Menu.Trigger</code>, <code>Menu.Content</code>, <code>Menu.Item</code> and a few more — rather than configured through
  a wall of props.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <MenuBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><MenuBasic /></Example>
<p class="t-body t-muted">Checkbox and radio items, a label over a group, and a shortcut shown at the end:</p>
<Example html={code('Full')}><MenuFull /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  <code>MenuButton</code> is the secondary button that opens a menu of <code>items</code>; <code>Menu.show</code> opens
  it from an opener of your own. <code>MenuItem</code> takes <code>onSelect</code>, an optional <code>icon</code> and
  <code>shortcut</code>, <code>checked</code> for a checkbox item, <code>destructive</code> and <code>disabled</code>;
  <code>MenuItem.radio(…, checked:)</code> is a radio option (announced as a radio menu item, ticked when checked; the
  caller moves the check in <code>onSelect</code>), <code>MenuItem.label(…)</code> a heading over a few items (not
  focusable, not chosen) and <code>MenuItem.separator()</code> a hairline.
</p>
<CodeBlock html={code('FLUTTER_MENU_BUTTON')} />
<p class="t-body t-muted">
  <code>Menu.show</code> anchors the menu to the render box of the context it gets, aligned to its end edge:
</p>
<CodeBlock html={code('FLUTTER_SHOW')} />
<GalleryShot id="menu" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">Menu.Root</h3>
<PropsTable rows={rootProps} />
<h3 class="t-title-s">Menu.Trigger</h3>
<PropsTable rows={triggerProps} />
<h3 class="t-title-s">Menu.Content</h3>
<PropsTable rows={contentProps} />
<h3 class="t-title-s">Menu.Item</h3>
<PropsTable rows={itemProps} />
<h3 class="t-title-s">Menu.CheckboxItem</h3>
<PropsTable rows={checkboxItemProps} />
<h3 class="t-title-s">Menu.RadioGroup</h3>
<PropsTable rows={radioGroupProps} />
<h3 class="t-title-s">Menu.RadioItem</h3>
<PropsTable rows={radioItemProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Menu', 'MenuButton', 'MenuItem']} />

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Enter / Space / ↓ (on the trigger)', action: 'Opens the menu, on its first item.' },
    { keys: '↑ (on the trigger)', action: 'Opens the menu, on its last item.' },
    { keys: '↑ / ↓', action: 'Moves, wrapping at the ends.' },
    { keys: 'Home / End', action: 'Moves to the first or last item.' },
    { keys: 'A letter', action: 'Jumps to the next item starting with it.' },
    { keys: 'Enter / Space', action: 'Chooses the focused item, then closes the menu.' },
    { keys: 'Escape / Tab', action: 'Closes the menu; Escape returns focus to the trigger.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Rename, menu item, 1 of 3." A shortcut is seen, not read, unless the item also has <code>aria-keyshortcuts</code>.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont doCaption="a destructive item last, after a separator." dontCaption="mix a destructive item in with the rest.">
  {#snippet doExample()}<MenuDoDestructiveLast />{/snippet}
  {#snippet dontExample()}<MenuDontMixed />{/snippet}
</DoDont>
