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

  import BadgeBasic from '#lib/examples/badge/Basic.svelte';
  import BadgeCounts from '#lib/examples/badge/Counts.svelte';
  import BadgeDoMeaningInLabel from '#lib/examples/badge/DoMeaningInLabel.svelte';
  import BadgeDontSilentBadge from '#lib/examples/badge/DontSilentBadge.svelte';
  import BadgeOnAvatar from '#lib/examples/badge/OnAvatar.svelte';
  import BadgePreview from '#lib/examples/badge/Preview.svelte';

  import badgeProps from '../../../../.generated/props/badge.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Badge — tsuya</title>
</svelte:head>

<PageHeader title="Badge" subtitle="Content" />

<p class="t-body-l">
  A count pill ("99+" above 99) or a dot, pinned on the corner of a host: an icon button, an avatar. It is decorative:
  what it means belongs in the host's accessible name. Do not use it alone, in text; use Chip for a label the user can
  read or press.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Preview')}>
  <BadgePreview />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><BadgeBasic /></Example>
<p class="t-body t-muted">A count above 99 reads "99+"; a dot has no number.</p>
<Example html={code('Counts')}><BadgeCounts /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<CodeBlock html={code('FLUTTER_BASIC')} />
<p class="t-body t-muted">A dot:</p>
<CodeBlock html={code('FLUTTER_DOT')} />
<GalleryShot id="badge" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={badgeProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Badge']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  A count is a pill, 18 tall, in the accent; a dot is an 8 px accent circle. Pass neither and nothing renders. The hosts
  that take one through a <code>badge</code> snippet are IconButton and Avatar; TabBar items take a <code>badge</code> of
  their own.
</p>
<Example html={code('OnAvatar')}><BadgeOnAvatar /></Example>

<h2 class="t-title-l">Keyboard</h2>
<p class="t-body">None: a badge is not focusable. Its host is.</p>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  A badge is hidden from screen readers; the host says what it means: "Notifications, 3 unread, button."
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="put the badge's meaning in the host's label."
  dontCaption="leave the label at the name alone: what the badge says is lost."
>
  {#snippet doExample()}<BadgeDoMeaningInLabel />{/snippet}
  {#snippet dontExample()}<BadgeDontSilentBadge />{/snippet}
</DoDont>
