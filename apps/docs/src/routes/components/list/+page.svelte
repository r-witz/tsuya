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

  import ListBasic from '#lib/examples/list/Basic.svelte';
  import ListCurrent from '#lib/examples/list/Current.svelte';
  import ListDoDestructiveLast from '#lib/examples/list/DoDestructiveLast.svelte';
  import ListDontDestructiveMixed from '#lib/examples/list/DontDestructiveMixed.svelte';
  import ListLeading from '#lib/examples/list/Leading.svelte';
  import ListPreview from '#lib/examples/list/Preview.svelte';
  import ListSelectable from '#lib/examples/list/Selectable.svelte';
  import ListTall from '#lib/examples/list/Tall.svelte';

  import listProps from '../../../../.generated/props/list.json' with { type: 'json' };
  import listItemProps from '../../../../.generated/props/list-item.json' with { type: 'json' };
  import sectionProps from '../../../../.generated/props/section.json' with { type: 'json' };
</script>

<svelte:head>
  <title>List — tsuya</title>
</svelte:head>

<PageHeader title="List, ListItem and Section" subtitle="Content" />

<p class="t-body-l">
  Full-width rows separated by hairlines, instead of cards: <code>List</code> holds <code>ListItem</code> rows, which
  may be a link, a button or a plain row, and <code>Section</code> groups them under a label. Use Accordion for rows that
  open their content, and Menu for actions anchored to a control.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <ListPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  A row is a link with <code>href</code>, a button with <code>onclick</code>, and a plain row with neither.
</p>
<Example html={code('Basic')}><ListBasic /></Example>
<p class="t-body t-muted">An icon (20), an avatar (40) or a thumbnail (40 to 48) leads; a value or a control trails.</p>
<Example html={code('Leading')}><ListLeading /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">A row:</p>
<CodeBlock html={code('FLUTTER_LIST_ITEM')} />
<p class="t-body t-muted">A group of rows under a label:</p>
<CodeBlock html={code('FLUTTER_SECTION')} />
<GalleryShot id="list" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">List</h3>
<PropsTable rows={listProps} />
<h3 class="t-title-s">ListItem</h3>
<PropsTable rows={listItemProps} />
<h3 class="t-title-s">Section</h3>
<PropsTable rows={sectionProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['ListItem', 'Section']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  <code>current</code> bolds the title and sets <code>aria-current</code>; <code>tall</code> grows the row for an
  account row; <code>destructive</code> puts the title in the danger colour, and belongs alone in the last group. In a
  selectable list, <code>selected</code> puts a tick at the end.
</p>
<Example html={code('Current')}><ListCurrent /></Example>
<Example html={code('Tall')}><ListTall /></Example>
<Example html={code('Selectable')}><ListSelectable /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to a row that is a link or a button; a plain row is not a tab stop.' },
    { keys: 'Enter', action: 'Follows a link row, or presses a button row.' },
    { keys: 'Space', action: 'Presses a button row.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Notifications, link." A current row is also announced as current. In a selectable list, a selected button row is a
  pressed toggle ("Name, toggle button, pressed"); a link or a plain row is followed by "selected". A <code
    >Section</code
  > is read as a group named by its label.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="keep a destructive row alone, in the last group."
  dontCaption="mix a destructive row in with the others."
>
  {#snippet doExample()}<ListDoDestructiveLast />{/snippet}
  {#snippet dontExample()}<ListDontDestructiveMixed />{/snippet}
</DoDont>
