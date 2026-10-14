// 11.4 Field, 11.5 TextField (with the textarea and the search), 11.12 Combobox.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

void _noop() {}

/// The screens of the text inputs.
final textInputEntries = [
  GalleryEntry.component('field', 'Field', 'The frame of a control: label, hint or error.', _field),
  GalleryEntry.component('text-field', 'TextField', 'A line of text, a textarea or a search.', _textField),
  GalleryEntry.component('combobox', 'Combobox', 'A text input that filters a list of options.', _combobox),
];

Widget _field(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Around a custom control',
      child: Hold<double>(
        initial: 0.4,
        builder: (context, value, set) => Field(
          label: 'Crossfade',
          hint: '${(value * 12).round()} seconds between tracks',
          child: Slider(value: value, onChanged: set, label: 'Crossfade'),
        ),
      ),
    ),
    Demo(
      'An error replaces the hint',
      child: Hold<String?>(
        initial: null,
        builder: (context, value, set) => Field(
          label: 'Playlist',
          hint: 'Shown to the people you share it with',
          error: value == null ? 'Pick a playlist to add the track to' : null,
          required: true,
          child: Select<String>(
            label: 'Playlist',
            value: value,
            onChanged: set,
            placeholder: 'Choose a playlist',
            options: const [
              ListboxOption(value: 'morning', label: 'Morning'),
              ListboxOption(value: 'focus', label: 'Focus'),
            ],
          ),
        ),
      ),
    ),
    const Demo(
      'Optional',
      child: Field(
        label: 'Note',
        optional: true,
        child: Variants([Chip(label: 'Add a note', selected: false, onPressed: _noop)]),
      ),
    ),
  ],
);

Widget _textField(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Demo(
      'Empty and filled',
      child: Stacked([
        TextField(label: 'Name', placeholder: 'Your name'),
        _Filled(label: 'Email', text: 'mira@example.com', hint: 'We send the receipt here'),
      ]),
    ),
    const Demo(
      'Required, optional',
      child: Stacked([
        TextField(label: 'Display name', required: true, placeholder: 'Mira Vale'),
        TextField(label: 'Website', optional: true, placeholder: 'https://'),
      ]),
    ),
    const Demo(
      'Error and disabled',
      child: Stacked([
        _Filled(label: 'Email', text: 'mira@example', error: 'Enter an address like name@example.com'),
        _Filled(label: 'Username', text: 'mira.vale', enabled: false),
      ]),
    ),
    const Demo(
      'Leading and trailing',
      child: Stacked([
        TextField(
          label: 'Search by artist',
          leading: GIconView(GIcon.user, size: 20),
          placeholder: 'Artist',
          clearable: true,
        ),
        _Filled(label: 'Length', text: '42', trailing: _Unit('min')),
      ]),
    ),
    const Demo(
      'Password',
      child: _Filled(label: 'Password', text: 'correct horse', obscureText: true),
    ),
    const Demo(
      'Textarea',
      child: _Filled(
        label: 'Description',
        text: 'Recorded in one take at the harbour studio, with the doors open to the tide.',
        maxLines: 6,
        minLines: 2,
      ),
    ),
    const Demo(
      'Search',
      child: Stacked([
        TextField.search(label: 'Search', placeholder: 'Search albums'),
        TextField.search(label: 'Search', placeholder: 'Search albums', size: TextFieldSize.sm),
        _Filled(label: 'Search', text: 'low tide', search: true),
      ], gap: TsuyaSpace.s12),
    ),
    const Demo(
      'Search, glass, over artwork',
      child: OverArtwork(
        height: 96,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: TsuyaSpace.s16),
          child: TextField.search(label: 'Search', placeholder: 'Search', glass: true),
        ),
      ),
    ),
  ],
);

class _Unit extends StatelessWidget {
  const _Unit(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    return Text(text, style: theme.text(TsuyaType.small).copyWith(color: theme.colors.textMuted));
  }
}

// a field that starts with some text, which needs a controller that outlives the build
class _Filled extends StatelessWidget {
  const _Filled({
    required this.label,
    required this.text,
    this.hint,
    this.error,
    this.enabled = true,
    this.obscureText = false,
    this.search = false,
    this.maxLines = 1,
    this.minLines,
    this.trailing,
  });

  final String label;
  final String text;
  final String? hint;
  final String? error;
  final bool enabled;
  final bool obscureText;
  final bool search;
  final int maxLines;
  final int? minLines;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => TextHold(
    text: text,
    builder: (context, controller) => search
        ? TextField.search(label: label, controller: controller)
        : TextField(
            label: label,
            controller: controller,
            hint: hint,
            error: error,
            enabled: enabled,
            obscureText: obscureText,
            maxLines: maxLines,
            minLines: minLines,
            trailing: trailing,
          ),
  );
}

const _artists = [
  ListboxOption(value: 'mira', label: 'Mira Vale', group: 'Artists'),
  ListboxOption(value: 'harbour', label: 'The Harbour Club', group: 'Artists'),
  ListboxOption(value: 'noa', label: 'Noa Reyes', group: 'Artists'),
  ListboxOption(value: 'juniper', label: 'Juniper Lane', group: 'Artists'),
  ListboxOption(value: 'sol', label: 'Sol Arkin', group: 'Artists'),
];

Widget _combobox(BuildContext context) => const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Choose from a list',
      child: Combobox<String>(
        label: 'Artist',
        placeholder: 'Type a name',
        hint: 'Start typing to filter',
        options: _artists,
      ),
    ),
    Demo(
      'Free text allowed',
      child: Combobox<String>(label: 'Tag', placeholder: 'Type or pick', freeText: true, options: _artists),
    ),
    Demo(
      'Loading and error',
      child: Stacked([
        Combobox<String>(label: 'Artist', placeholder: 'Searching…', loading: true, options: []),
        Combobox<String>(label: 'Artist', options: _artists, required: true, error: 'Pick an artist from the list'),
      ]),
    ),
    Demo(
      'Disabled',
      child: Combobox<String>(label: 'Artist', enabled: false, options: _artists),
    ),
  ],
);
