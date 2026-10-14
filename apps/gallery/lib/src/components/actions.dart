// 11.1 Button, 11.2 IconButton, 11.3 Chip.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

void _noop() {}

/// The screens of the actions.
final actionEntries = [
  GalleryEntry.component('button', 'Button', 'A labelled action. One accent-filled action per screen.', _button),
  GalleryEntry.component('icon-button', 'IconButton', 'An icon-only action or a toggle, always named.', _iconButton),
  GalleryEntry.component('chip', 'Chip', 'A filter or a sort option, alone or in a group.', _chip),
];

Widget _button(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Demo(
      'Kinds',
      child: Variants([
        Button(label: 'Play', kind: ButtonKind.primary, onPressed: _noop),
        Button(label: 'Save', onPressed: _noop),
        Button(label: 'Skip', kind: ButtonKind.ghost, onPressed: _noop),
        Button(label: 'Delete', kind: ButtonKind.danger, onPressed: _noop),
      ]),
    ),
    const Demo(
      'Glass, over artwork',
      child: OverArtwork(
        child: Button(label: 'Shuffle', kind: ButtonKind.glass, onPressed: _noop),
      ),
    ),
    const Demo(
      'Sizes',
      child: Variants([
        Button(label: 'Small', size: ButtonSize.sm, kind: ButtonKind.primary, onPressed: _noop),
        Button(label: 'Medium', kind: ButtonKind.primary, onPressed: _noop),
        Button(label: 'Large', size: ButtonSize.lg, kind: ButtonKind.primary, onPressed: _noop),
      ]),
    ),
    Demo(
      'With an icon',
      child: Variants([
        Button(label: 'Download', icon: const GIconView(GIcon.download), kind: ButtonKind.primary, onPressed: _noop),
        Button(label: 'Share', icon: const GIconView(GIcon.share), onPressed: _noop),
        Button(label: 'Add', icon: const GIconView(GIcon.plus), kind: ButtonKind.ghost, onPressed: _noop),
      ]),
    ),
    const Demo(
      'Loading and disabled',
      child: Variants([
        Button(label: 'Saving', loading: true, kind: ButtonKind.primary, onPressed: _noop),
        Button(label: 'Saving', loading: true, onPressed: _noop),
        Button(label: 'Unavailable', kind: ButtonKind.primary, onPressed: null),
        Button(label: 'Unavailable', onPressed: null),
      ]),
    ),
    const Demo(
      'Block',
      child: Stacked([
        Button(label: 'Continue', kind: ButtonKind.primary, block: true, size: ButtonSize.lg, onPressed: _noop),
        Button(label: 'Not now', kind: ButtonKind.ghost, block: true, onPressed: _noop),
      ], gap: TsuyaSpace.s8),
    ),
    const Demo(
      'A long label ends with an ellipsis',
      child: SizedBox(
        width: 220,
        child: Button(label: 'Add every track of this record to the queue', block: true, onPressed: _noop),
      ),
    ),
  ],
);

Widget _iconButton(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Demo(
      'Kinds',
      child: Variants([
        IconButton(icon: GIconView(GIcon.heart), label: 'Like', onPressed: _noop),
        IconButton(icon: GIconView(GIcon.more), label: 'More', kind: IconButtonKind.plain, onPressed: _noop),
        IconButton(icon: GIconView(GIcon.play), label: 'Play', kind: IconButtonKind.accent, onPressed: _noop),
      ]),
    ),
    const Demo(
      'Glass, over artwork',
      child: OverArtwork(
        child: IconButton(icon: GIconView(GIcon.share), label: 'Share', kind: IconButtonKind.glass, onPressed: _noop),
      ),
    ),
    Demo(
      'Sizes',
      child: Variants([
        const IconButton(icon: GIconView(GIcon.plus), label: 'Add', size: IconButtonSize.sm, onPressed: _noop),
        const IconButton(icon: GIconView(GIcon.plus), label: 'Add', onPressed: _noop),
        const IconButton(icon: GIconView(GIcon.plus), label: 'Add', size: IconButtonSize.lg, onPressed: _noop),
        IconButton(
          icon: const GIconView(GIcon.play),
          label: 'Play',
          kind: IconButtonKind.accent,
          size: IconButtonSize.custom(72),
          onPressed: _noop,
        ),
      ]),
    ),
    Demo(
      'Toggle',
      child: Hold<bool>(
        initial: true,
        builder: (context, on, set) => Variants([
          IconButton(icon: const GIconView(GIcon.heart), label: 'Like', toggled: on, onPressed: () => set(!on)),
          IconButton(icon: const GIconView(GIcon.heart), label: 'Like', toggled: !on, onPressed: () => set(!on)),
        ]),
      ),
    ),
    const Demo(
      'With a badge',
      child: Variants([
        IconButton(icon: GIconView(GIcon.bell), label: 'Notifications, 3 new', badge: Badge.count(3), onPressed: _noop),
        IconButton(icon: GIconView(GIcon.mail), label: 'Inbox, new', badge: Badge.dot(), onPressed: _noop),
        IconButton(
          icon: GIconView(GIcon.bell),
          label: 'Notifications, many',
          badge: Badge.count(120),
          onPressed: _noop,
        ),
      ]),
    ),
    const Demo(
      'Disabled',
      child: Variants([
        IconButton(icon: GIconView(GIcon.heart), label: 'Like', onPressed: null),
        IconButton(icon: GIconView(GIcon.play), label: 'Play', kind: IconButtonKind.accent, onPressed: null),
      ]),
    ),
  ],
);

Widget _chip(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Demo(
      'States',
      child: Variants([
        Chip(label: 'Recent', selected: false, onPressed: _noop),
        Chip(label: 'Albums', selected: true, onPressed: _noop),
        Chip(label: 'Unavailable', selected: false, onPressed: null),
        Chip(label: 'Rock', selected: false, icon: GIconView(GIcon.album), onPressed: _noop),
      ]),
    ),
    const Demo(
      'Glass, over artwork',
      child: OverArtwork(
        child: Chip(label: 'Shuffle', selected: false, glass: true, onPressed: _noop),
      ),
    ),
    Demo(
      'One choice',
      child: Hold<Set<String>>(
        initial: {'recent'},
        builder: (context, value, set) => ChipGroup<String>(
          label: 'Sort',
          value: value,
          onChanged: set,
          chips: const [
            ChipOption(value: 'recent', label: 'Recent'),
            ChipOption(value: 'title', label: 'Title'),
            ChipOption(value: 'artist', label: 'Artist'),
            ChipOption(value: 'year', label: 'Year'),
            ChipOption(value: 'plays', label: 'Most played'),
          ],
        ),
      ),
    ),
    Demo(
      'Several choices',
      child: Hold<Set<String>>(
        initial: {'jazz', 'folk'},
        builder: (context, value, set) => ChipGroup<String>(
          label: 'Genres',
          multiple: true,
          value: value,
          onChanged: set,
          chips: const [
            ChipOption(value: 'jazz', label: 'Jazz'),
            ChipOption(value: 'folk', label: 'Folk'),
            ChipOption(value: 'electronic', label: 'Electronic'),
            ChipOption(value: 'ambient', label: 'Ambient'),
          ],
        ),
      ),
    ),
  ],
);
