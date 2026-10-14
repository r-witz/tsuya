// 11.6 Checkbox, 11.7 RadioGroup, 11.8 Switch, 11.9 SegmentedControl, 11.10 Slider, 11.11 Select.
import 'package:flutter/widgets.dart' hide RadioGroup;
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

/// The screens of the controls that choose or set a value.
final choiceInputEntries = [
  GalleryEntry.component('checkbox', 'Checkbox', 'A choice that is on, off or, for a group, mixed.', _checkbox),
  GalleryEntry.component('radio-group', 'RadioGroup', 'One choice among a few, all in view.', _radioGroup),
  GalleryEntry.component('switch', 'Switch', 'A setting that applies at once.', _switch),
  GalleryEntry.component('segmented-control', 'SegmentedControl', 'Two to five options, one always on.', _segmented),
  GalleryEntry.component('slider', 'Slider', 'A value in a range.', _slider),
  GalleryEntry.component('select', 'Select', 'A choice in a longer list.', _select),
];

Widget _checkbox(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'States',
      child: Hold<bool>(
        initial: true,
        builder: (context, on, set) => Stacked([
          Checkbox(value: on, onChanged: (v) => set(v!), label: 'Download over Wi-Fi only'),
          Checkbox(value: !on, onChanged: (v) => set(!v!), label: 'Keep the screen on while playing'),
        ], gap: TsuyaSpace.s4),
      ),
    ),
    Demo(
      'A group with a mixed parent',
      child: Hold<(bool, bool)>(
        initial: (true, false),
        builder: (context, v, set) {
          final all = v.$1 && v.$2 ? true : (v.$1 || v.$2 ? null : false);
          return Stacked([
            Checkbox(
              value: all,
              tristate: true,
              onChanged: (_) => set(all == true ? (false, false) : (true, true)),
              label: 'Notify me about',
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: TsuyaSpace.s32),
              child: Stacked([
                Checkbox(value: v.$1, onChanged: (x) => set((x!, v.$2)), label: 'New releases'),
                Checkbox(value: v.$2, onChanged: (x) => set((v.$1, x!)), label: 'Concerts nearby'),
              ], gap: TsuyaSpace.s4),
            ),
          ], gap: TsuyaSpace.s4);
        },
      ),
    ),
    const Demo(
      'Disabled',
      child: Stacked([
        Checkbox(value: true, onChanged: null, label: 'Explicit content filter'),
        Checkbox(value: false, onChanged: null, label: 'Share listening activity'),
      ], gap: TsuyaSpace.s4),
    ),
  ],
);

Widget _radioGroup(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'A group',
      child: Hold<String>(
        initial: 'high',
        builder: (context, value, set) => RadioGroup<String>(
          label: 'Streaming quality',
          value: value,
          onChanged: set,
          options: const [
            RadioOption(value: 'low', label: 'Low, saves data'),
            RadioOption(value: 'normal', label: 'Normal'),
            RadioOption(value: 'high', label: 'High'),
            RadioOption(value: 'lossless', label: 'Lossless, uses a lot of data'),
          ],
        ),
      ),
    ),
    Demo(
      'Nothing chosen yet',
      child: Hold<String?>(
        initial: null,
        builder: (context, value, set) => RadioGroup<String>(
          label: 'Sort albums by',
          value: value,
          onChanged: set,
          options: const [
            RadioOption(value: 'title', label: 'Title'),
            RadioOption(value: 'artist', label: 'Artist'),
          ],
        ),
      ),
    ),
  ],
);

Widget _switch(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'On and off',
      child: Hold<(bool, bool)>(
        initial: (true, false),
        builder: (context, v, set) => Stacked([
          Switch(value: v.$1, onChanged: (x) => set((x, v.$2)), label: 'Crossfade'),
          Switch(value: v.$2, onChanged: (x) => set((v.$1, x)), label: 'Normalise volume'),
        ], gap: TsuyaSpace.s8),
      ),
    ),
    const Demo(
      'Disabled',
      child: Stacked([
        Switch(value: true, onChanged: null, label: 'Offline mode'),
        Switch(value: false, onChanged: null, label: 'Data saver'),
      ], gap: TsuyaSpace.s8),
    ),
    const Demo(
      'Without a label, named by its row',
      child: Variants([Switch(value: true, onChanged: null), Switch(value: false, onChanged: null)]),
    ),
  ],
);

Widget _segmented(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Text',
      child: Hold<String>(
        initial: 'grid',
        builder: (context, value, set) => SegmentedControl<String>(
          label: 'View',
          selected: value,
          onChanged: set,
          segments: const [
            Segment(value: 'grid', label: 'Grid'),
            Segment(value: 'list', label: 'List'),
          ],
        ),
      ),
    ),
    Demo(
      'Icons only, still named',
      child: Hold<String>(
        initial: 'list',
        builder: (context, value, set) => SegmentedControl<String>(
          label: 'View',
          selected: value,
          onChanged: set,
          segments: const [
            Segment(value: 'grid', label: 'Grid', icon: GIconView(GIcon.grid)),
            Segment(value: 'list', label: 'List', icon: GIconView(GIcon.list)),
          ],
        ),
      ),
    ),
    Demo(
      'Expanded, five options',
      child: Hold<String>(
        initial: 'week',
        builder: (context, value, set) => SegmentedControl<String>(
          label: 'Range',
          expand: true,
          selected: value,
          onChanged: set,
          segments: const [
            Segment(value: 'day', label: 'Day'),
            Segment(value: 'week', label: 'Week'),
            Segment(value: 'month', label: 'Month'),
            Segment(value: 'year', label: 'Year'),
            Segment(value: 'all', label: 'All'),
          ],
        ),
      ),
    ),
  ],
);

Widget _slider(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'A value of 0 to 1',
      child: Hold<double>(
        initial: 0.35,
        builder: (context, value, set) => Slider(value: value, onChanged: set, label: 'Volume'),
      ),
    ),
    Demo(
      'With steps and a spoken value',
      child: Hold<double>(
        initial: 3,
        builder: (context, value, set) => Slider(
          value: value,
          onChanged: set,
          label: 'Sleep timer',
          min: 0,
          max: 12,
          step: 1,
          valueLabel: (v) => v == 0 ? 'Off' : '${v.round()} hours',
        ),
      ),
    ),
    const Demo('Disabled', child: Slider(value: 0.6, onChanged: null, label: 'Brightness')),
  ],
);

const _languages = [
  ListboxOption(value: 'en', label: 'English', group: 'Common'),
  ListboxOption(value: 'fr', label: 'French', group: 'Common'),
  ListboxOption(value: 'es', label: 'Spanish', group: 'Common'),
  ListboxOption(value: 'de', label: 'German', group: 'Others'),
  ListboxOption(value: 'it', label: 'Italian', group: 'Others'),
  ListboxOption(value: 'nl', label: 'Dutch', group: 'Others', disabled: true),
];

Widget _select(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Placeholder',
      child: Hold<String?>(
        initial: null,
        builder: (context, value, set) => Select<String>(
          label: 'Language',
          value: value,
          onChanged: set,
          placeholder: 'Choose a language',
          options: _languages,
        ),
      ),
    ),
    Demo(
      'Chosen',
      child: Hold<String?>(
        initial: 'fr',
        builder: (context, value, set) =>
            Select<String>(label: 'Language', value: value, onChanged: set, options: _languages),
      ),
    ),
    const Demo(
      'Disabled',
      child: Select<String>(label: 'Language', value: 'en', onChanged: null, options: _languages),
    ),
  ],
);
