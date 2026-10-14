<script lang="ts">
  import { PageHeader } from '@tsuya/svelte';

  import { code } from '#lib/doc/code.ts';
  import CodeBlock from '#lib/doc/CodeBlock.svelte';
  import GalleryShot from '#lib/doc/GalleryShot.svelte';
  import DartApi from '#lib/doc/DartApi.svelte';
  import DoDont from '#lib/doc/DoDont.svelte';
  import Example from '#lib/doc/Example.svelte';
  import PreviewStage from '#lib/doc/PreviewStage.svelte';
  import PropsTable from '#lib/doc/PropsTable.svelte';

  import AvatarBasic from '#lib/examples/avatar/Basic.svelte';
  import AvatarColors from '#lib/examples/avatar/Colors.svelte';
  import AvatarDoBadgeInLabel from '#lib/examples/avatar/DoBadgeInLabel.svelte';
  import AvatarDontBadgeSilent from '#lib/examples/avatar/DontBadgeSilent.svelte';
  import AvatarPhoto from '#lib/examples/avatar/Photo.svelte';
  import AvatarPreview from '#lib/examples/avatar/Preview.svelte';
  import AvatarSizes from '#lib/examples/avatar/Sizes.svelte';
  import AvatarWithBadge from '#lib/examples/avatar/WithBadge.svelte';

  import avatarProps from '../../../../.generated/props/avatar.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Avatar — tsuya</title>
</svelte:head>

<PageHeader title="Avatar" subtitle="Content" />

<p class="t-body-l">
  A person's avatar: round, the photo, or their initials on a fill, or on a gradient of their own colours when white
  stays readable on it. It is decorative unless it has a <code>label</code>. Use Thumbnail instead for the picture of a
  content (an album, a poster), which is not round.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')} sizes={['sm', 'md', 'lg']}>
  {#snippet children({ size })}
    <AvatarPreview {size} />
  {/snippet}
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><AvatarBasic /></Example>
<p class="t-body t-muted">With a photo, the initials show while it loads, and if it fails.</p>
<Example html={code('Photo')}><AvatarPhoto /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<GalleryShot id="avatar" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={avatarProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Avatar']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  The default is 40; any size works, and the initials scale with it (36 % of the size). <code>colors</code> gives a
  gradient from the top start corner: it is dropped, for the neutral fill, when white would not reach 4.5:1 on the
  darker of the two colours, checked at runtime. A <code>badge</code> is pinned on the corner.
</p>
<Example html={code('Sizes')}><AvatarSizes /></Example>
<Example html={code('Colors')}><AvatarColors /></Example>
<p class="t-body t-muted">A badge is decorative: put what it means in the label.</p>
<Example html={code('WithBadge')}><AvatarWithBadge /></Example>

<h2 class="t-title-l">Keyboard</h2>
<p class="t-body">
  None: an avatar is not interactive. Put it in a button or a link when pressing it should do something.
</p>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">"Ada Lovelace, image." Without a <code>label</code>, an avatar is hidden from screen readers.</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="fold a badge's meaning into the label."
  dontCaption="pin a badge and leave the label as the name alone."
>
  {#snippet doExample()}<AvatarDoBadgeInLabel />{/snippet}
  {#snippet dontExample()}<AvatarDontBadgeSilent />{/snippet}
</DoDont>
