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

  import SliderBasic from '#lib/examples/slider/Basic.svelte';
  import SliderDoValue from '#lib/examples/slider/DoValue.svelte';
  import SliderDontExact from '#lib/examples/slider/DontExact.svelte';
  import SliderSteps from '#lib/examples/slider/Steps.svelte';

  import sliderProps from '../../../../.generated/props/slider.json' with { type: 'json' };
</script>

<svelte:head>
  <title>Slider — tsuya</title>
</svelte:head>

<PageHeader title="Slider" subtitle="Inputs" />

<p class="t-body-l">
  A value on a range, picked by dragging or with the keys: a native range input drawn as a track filled with the accent,
  and a 20 thumb. Use it where the feel matters more than the exact number, such as a volume or a brightness, and show
  the value next to it when it does matter. Use a TextInput for an exact number.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')}>
  <SliderBasic />
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<p class="t-body t-muted">
  The label names the slider for assistive technology; it is not drawn. The range is 0 to 1 by default, as in Flutter,
  and the step a twentieth of it; the announced value is still a percentage. Give <code>min</code> and <code>max</code> for
  any other range.
</p>
<Example html={code('Basic')}><SliderBasic /></Example>
<p class="t-body t-muted">
  A range, a step and the text announced for the value (<code>valueLabel</code>) are set together:
</p>
<Example html={code('Steps')}><SliderSteps /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  Material also has a <code>Slider</code>: an app that imports it too imports tsuya with a prefix (<code
    >import 'package:tsuya/tsuya.dart' as t;</code
  >).
</p>
<CodeBlock html={code('FLUTTER_SLIDER')} />
<GalleryShot id="slider" />

<h2 class="t-title-l">Props</h2>
<PropsTable rows={sliderProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['Slider']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  There is one look. The fill runs from the start edge, so it runs from the right in a right-to-left layout; the thumb
  carries a hairline ring, so that it keeps 3:1 against its track.
</p>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the thumb.' },
    { keys: '← / ↓ and → / ↑', action: 'Moves the value by one step (a twentieth of the range by default).' },
    { keys: 'PageDown / PageUp', action: 'Moves the value by a tenth of the range.' },
    { keys: 'Home / End', action: 'Moves the value to the minimum or the maximum.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Volume, slider, 40 %." The value is announced as a percentage of the range, unless <code>valueLabel</code> gives its own
  text.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="show the value next to the slider when it matters."
  dontCaption="use a slider for a number that has to be exact; use a TextInput."
>
  {#snippet doExample()}<SliderDoValue />{/snippet}
  {#snippet dontExample()}<SliderDontExact />{/snippet}
</DoDont>
