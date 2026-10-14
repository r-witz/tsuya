// 11.15 Thumbnail, 11.16 Avatar, 11.17 Badge, 11.18 Progress, 11.19 Spinner, 11.20 Skeleton.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/covers.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

void _noop() {}

/// The screens of the content components.
final contentEntries = [
  GalleryEntry.component('thumbnail', 'Thumbnail', 'The picture of a content, in three shapes.', _thumbnail),
  GalleryEntry.component('avatar', 'Avatar', 'A person: a photo, initials, or their colours.', _avatar),
  GalleryEntry.component('badge', 'Badge', 'A count or a dot pinned to its host.', _badge),
  GalleryEntry.component('progress', 'Progress', 'How far along something is, or that it is working.', _progress),
  GalleryEntry.component('spinner', 'Spinner', 'Something is loading and nothing else is known.', _spinner),
  GalleryEntry.component('skeleton', 'Skeleton', 'Placeholders at the final size of what loads.', _skeleton),
  GalleryEntry.component('glyph', 'Glyph', 'The twelve icons tsuya draws itself, the same on both platforms.', _glyph),
];

Widget _thumbnail(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Shapes',
      child: Variants([
        Thumbnail(image: covers[0].image, size: 96, label: covers[0].title),
        Thumbnail(image: covers[1].image, size: 96, ratio: ThumbnailRatio.portrait, label: covers[1].title),
        Thumbnail(image: covers[2].image, size: 160, ratio: ThumbnailRatio.wide, label: covers[2].title),
      ], spacing: TsuyaSpace.s16),
    ),
    Demo(
      'The radius grows with the width',
      child: Variants([
        for (final size in [32.0, 40.0, 64.0, 120.0, 160.0, 200.0]) Thumbnail(image: covers[3].image, size: size),
      ], spacing: TsuyaSpace.s16),
    ),
    const Demo(
      'Placeholder, without a picture',
      child: Variants([
        Thumbnail(size: 64),
        Thumbnail(size: 96, placeholder: GIconView(GIcon.album, size: 28)),
        Thumbnail(size: 96, ratio: ThumbnailRatio.portrait, placeholder: GIconView(GIcon.album, size: 28)),
      ], spacing: TsuyaSpace.s16),
    ),
  ],
);

Widget _avatar(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Photo',
      child: Variants([
        Avatar(image: covers[4].image, size: 32, label: 'Sol Arkin'),
        Avatar(image: covers[4].image, label: 'Sol Arkin'),
        Avatar(image: covers[4].image, size: 72, label: 'Sol Arkin'),
      ], spacing: TsuyaSpace.s16),
    ),
    const Demo(
      'Initials',
      child: Variants([
        Avatar(initials: 'MV', size: 32),
        Avatar(initials: 'NR'),
        Avatar(initials: 'JL', size: 72),
      ], spacing: TsuyaSpace.s16),
    ),
    const Demo(
      'On a gradient of the person\'s colours',
      child: Variants([
        Avatar(initials: 'KT', colors: (Color(0xFF5B3FA6), Color(0xFFC9569B))),
        Avatar(initials: 'SA', colors: (Color(0xFF0F5E7A), Color(0xFF2BA59B)), size: 56),
        // white would not keep 4.5:1 on these: the avatar falls back to the fill
        Avatar(initials: 'LP', colors: (Color(0xFFF6E27A), Color(0xFFF2B35E)), size: 56),
      ], spacing: TsuyaSpace.s16),
    ),
    const Demo(
      'With a badge',
      child: Variants([
        Avatar(initials: 'MV', size: 56, badge: Badge.dot()),
        Avatar(initials: 'NR', size: 56, badge: Badge.count(4)),
      ], spacing: TsuyaSpace.s24),
    ),
  ],
);

Widget _badge(BuildContext context) => const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Count and dot',
      child: Variants([Badge.count(1), Badge.count(24), Badge.count(99), Badge.count(120), Badge.dot()]),
    ),
    Demo(
      'Pinned on a host',
      child: Variants([
        IconButton(icon: GIconView(GIcon.bell), label: 'Notifications, 3 new', badge: Badge.count(3), onPressed: _noop),
        IconButton(icon: GIconView(GIcon.mail), label: 'Inbox, new', badge: Badge.dot(), onPressed: _noop),
        Avatar(initials: 'MV', size: 48, badge: Badge.count(12)),
      ], spacing: TsuyaSpace.s24),
    ),
  ],
);

Widget _progress(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Demo(
      'Determinate',
      child: Stacked([
        Progress(value: 0.0, label: 'Download'),
        Progress(value: 0.4, label: 'Download'),
        Progress(value: 1.0, label: 'Download'),
      ]),
    ),
    const Demo('Thin, along an edge', child: Stacked([Progress(value: 0.65, label: 'Track position', thin: true)])),
    const Demo(
      'Without a value, a third of the bar crosses the track',
      child: Stacked([Progress(label: 'Syncing the library'), Progress(label: 'Syncing', thin: true)]),
    ),
  ],
);

Widget _spinner(BuildContext context) => const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Sizes',
      child: Variants([
        Spinner(size: SpinnerSize.sm, label: 'Loading'),
        Spinner(label: 'Loading'),
        Spinner(size: SpinnerSize.lg, label: 'Loading'),
      ], spacing: TsuyaSpace.s24),
    ),
    Demo(
      'In a labelled button, hidden from screen readers',
      child: Variants([Button(label: 'Saving', loading: true, kind: ButtonKind.primary, onPressed: _noop)]),
    ),
  ],
);

Widget _skeleton(BuildContext context) => const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'A row loading',
      child: Row(
        children: [
          Skeleton(width: 48, height: 48, radius: TsuyaRadius.xs),
          SizedBox(width: TsuyaSpace.s12),
          Expanded(child: Skeleton.text(lines: 2)),
        ],
      ),
    ),
    Demo('A paragraph', child: Skeleton.text(lines: 4)),
    Demo(
      'A cover and its title',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 160, height: 160, radius: TsuyaRadius.md),
          SizedBox(height: TsuyaSpace.s12),
          Skeleton(width: 120, height: 16, radius: TsuyaRadius.xs),
          SizedBox(height: TsuyaSpace.s8),
          Skeleton(width: 80, height: 12, radius: TsuyaRadius.xs),
        ],
      ),
    ),
  ],
);

Widget _glyph(BuildContext context) {
  final theme = TsuyaTheme.of(context);
  return Demo(
    'Sizes follow the icon slot; the two that point mirror in right-to-left',
    child: Wrap(
      spacing: TsuyaSpace.s16,
      runSpacing: TsuyaSpace.s16,
      children: [
        for (final glyph in TsuyaGlyph.values)
          SizedBox(
            width: 88,
            child: Column(
              children: [
                Glyph(glyph, size: 24),
                const SizedBox(height: TsuyaSpace.s8),
                Text(glyph.name, style: theme.text(TsuyaType.caption).copyWith(color: theme.colors.textMuted)),
              ],
            ),
          ),
      ],
    ),
  );
}
