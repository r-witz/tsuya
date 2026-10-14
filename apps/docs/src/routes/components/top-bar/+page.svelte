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

  import TopBarDoOneAction from '#lib/examples/top-bar/DoOneAction.svelte';
  import TopBarDontTwoActions from '#lib/examples/top-bar/DontTwoActions.svelte';
  import TopBarPreview from '#lib/examples/top-bar/Preview.svelte';
  import TopBarScreenBarBasic from '#lib/examples/top-bar/ScreenBarBasic.svelte';
  import TopBarScreenBarSubtitle from '#lib/examples/top-bar/ScreenBarSubtitle.svelte';
  import TopBarWithSearch from '#lib/examples/top-bar/WithSearch.svelte';

  import topBarProps from '../../../../.generated/props/top-bar.json' with { type: 'json' };
  import screenBarProps from '../../../../.generated/props/screen-bar.json' with { type: 'json' };
</script>

<svelte:head>
  <title>TopBar — tsuya</title>
</svelte:head>

<PageHeader title="TopBar and ScreenBar" subtitle="Disclosure and navigation" />

<p class="t-body-l">
  Two bars for two shells. <code>TopBar</code> is the app bar of a website or a desktop app: glass, floating 12 from the
  top and sides, with the brand, the navigation links, a search and icon buttons. <code>ScreenBar</code> is the bar of a pushed
  screen on a phone: a back button, a centred title, at most one action. Use PageHeader for the title of the page itself,
  and TabBar to move between the sections of a phone app.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <TopBarPreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">Snippets for the start, the centre (a search) and the end.</p>
<Example html={code('WithSearch')}><TopBarWithSearch /></Example>
<Example html={code('ScreenBarBasic')}><TopBarScreenBarBasic /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">A top bar:</p>
<CodeBlock html={code('FLUTTER_TOP_BAR')} />
<p class="t-body t-muted">A screen bar:</p>
<CodeBlock html={code('FLUTTER_SCREEN_BAR')} />
<GalleryShot id="top-bar" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">TopBar</h3>
<PropsTable rows={topBarProps} />
<h3 class="t-title-s">ScreenBar</h3>
<PropsTable rows={screenBarProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['TopBar', 'TopBarLink', 'ScreenBar']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  The links of a <code>TopBar</code> move into a menu at its end (a popover from a plain icon button, named by the
  <code>more</code>
  label) below the tablet width: narrow this window to see it. The current link takes <code>aria-current="page"</code>
  and a stronger fill. A <code>ScreenBar</code> has no back button without <code>onBack</code>, and
  <code>backLabel</code> goes with it.
</p>
<Example html={code('ScreenBarSubtitle')}><TopBarScreenBarSubtitle /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus through the links, the buttons and the back button.' },
    { keys: 'Enter', action: 'Follows a link.' },
    { keys: 'Enter / Space', action: 'Presses a button; on the menu button of a narrow TopBar, opens the menu.' },
    { keys: 'Escape', action: 'Closes the menu of a narrow TopBar.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  A link reads "Components, link, current page". The back button reads its <code>backLabel</code>: "Back, button". The
  title of a <code>ScreenBar</code> is a level 1 heading.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="one action at the end of a screen bar."
  dontCaption="put two actions in it: a screen bar has room for one."
>
  {#snippet doExample()}<TopBarDoOneAction />{/snippet}
  {#snippet dontExample()}<TopBarDontTwoActions />{/snippet}
</DoDont>
