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

  import TextInputBasic from '#lib/examples/text-input/Basic.svelte';
  import TextInputDoLabel from '#lib/examples/text-input/DoLabel.svelte';
  import TextInputDontPlaceholderLabel from '#lib/examples/text-input/DontPlaceholderLabel.svelte';
  import TextInputSearch from '#lib/examples/text-input/Search.svelte';
  import TextInputSlots from '#lib/examples/text-input/Slots.svelte';
  import TextInputStates from '#lib/examples/text-input/States.svelte';
  import TextInputTextarea from '#lib/examples/text-input/Textarea.svelte';

  import textInputProps from '../../../../.generated/props/text-input.json' with { type: 'json' };
  import textareaProps from '../../../../.generated/props/textarea.json' with { type: 'json' };
  import searchInputProps from '../../../../.generated/props/search-input.json' with { type: 'json' };
</script>

<svelte:head>
  <title>TextInput — tsuya</title>
</svelte:head>

<PageHeader title="TextInput" subtitle="Inputs" />

<p class="t-body-l">
  A text field: a native input in the field box, with leading and trailing slots, a clear button and, for a password, a
  show button. <code>Textarea</code> is the multi-line field and grows with its content; <code>SearchInput</code> is the pill
  for filtering what is on screen. Use Select or Combobox instead to choose among known options, and put any of them in a
  Field for its label, hint and error.
</p>

<h2 class="t-title-l">Preview</h2>
<PreviewStage html={code('Basic')} sizes={['md', 'sm']}>
  {#snippet children({ size })}
    <TextInputBasic size={size as 'sm' | 'md'} />
  {/snippet}
</PreviewStage>

<h2 class="t-title-l">Svelte usage</h2>
<Example html={code('Basic')}><TextInputBasic /></Example>
<p class="t-body t-muted">
  A unit or an icon goes in a slot; <code>clearable</code> adds the clear button, and a password gets its show button by itself.
</p>
<Example html={code('Slots')}><TextInputSlots /></Example>
<p class="t-body t-muted">Textarea grows with its text up to <code>maxRows</code>, then scrolls.</p>
<Example html={code('Textarea')}><TextInputTextarea /></Example>

<h2 class="t-title-l">Flutter usage</h2>
<p class="t-body t-muted">
  Material also has a <code>TextField</code>: an app that imports it too imports tsuya with a prefix (<code
    >import 'package:tsuya/tsuya.dart' as t;</code
  >). The label, hint and error are built in.
</p>
<CodeBlock html={code('FLUTTER_TEXT_FIELD')} />
<p class="t-body t-muted">
  A textarea is a <code>TextField</code> with <code>maxLines</code> above 1; it scrolls once it is reached.
</p>
<CodeBlock html={code('FLUTTER_TEXTAREA')} />
<p class="t-body t-muted">
  A search field is <code>TextField.search</code>; it defaults to the medium size, as <code>SearchInput</code> does;
  <code>size: TextFieldSize.sm</code> is the small one.
</p>
<CodeBlock html={code('FLUTTER_SEARCH')} />
<GalleryShot id="text-field" />

<h2 class="t-title-l">Props</h2>
<h3 class="t-title-s">TextInput</h3>
<PropsTable rows={textInputProps} />
<h3 class="t-title-s">Textarea</h3>
<PropsTable rows={textareaProps} />
<h3 class="t-title-s">SearchInput</h3>
<PropsTable rows={searchInputProps} />

<h2 class="t-title-l">Dart API</h2>
<DartApi types={['TextField', 'TextFieldSize']} />

<h2 class="t-title-l">Variants</h2>
<p class="t-body t-muted">
  SearchInput has a <code>sm</code> size and a <code>glass</code> variant, which only reads over artwork (DESIGN.md,
  rule 3). An <code>error</code> in the Field turns the boundary to the danger colour; a disabled field fades.
</p>
<Example html={code('Search')}><TextInputSearch /></Example>
<Example html={code('States')}><TextInputStates /></Example>

<h2 class="t-title-l">Keyboard</h2>
<KeyboardTable
  rows={[
    { keys: 'Tab', action: 'Moves focus to the field; the clear and show-password buttons are the next stops.' },
    {
      keys: 'Enter / Space (on the clear or show button)',
      action: 'Empties the field, or shows and hides the password.',
    },
    {
      keys: 'Typing, arrows, Home, End, Shift + arrows',
      action: "The platform's own text editing, as in any native field.",
    },
    { keys: 'Enter (in a Textarea)', action: 'Starts a new line.' },
  ]}
/>

<h2 class="t-title-l">Screen reader</h2>
<p class="t-body">
  "Email, edit text, required, Enter your work email." The hint is read after the name; an error replaces it and is read
  too, with the field marked invalid. A SearchInput reads its label, though it does not show it.
</p>

<h2 class="t-title-l">Do and don't</h2>
<DoDont
  doCaption="keep a visible label above the field, in a Field; the placeholder is only an example."
  dontCaption="use the placeholder as the label."
>
  {#snippet doExample()}<TextInputDoLabel />{/snippet}
  {#snippet dontExample()}<TextInputDontPlaceholderLabel />{/snippet}
</DoDont>
