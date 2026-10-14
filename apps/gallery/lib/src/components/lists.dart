// 11.13 List, ListItem and Section; 11.14 Header (the page header and the section header).
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/covers.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

void _noop() {}

/// The screens of the rows and the headers.
final listEntries = [
  GalleryEntry.component('list', 'List', 'Full-width rows under a section label, no card.', _list),
  GalleryEntry.component('header', 'Header', 'The title of a page, and of a section of it.', _header),
];

Widget _value(BuildContext context, String text) {
  final theme = TsuyaTheme.of(context);
  return Text(
    text,
    style: theme
        .text(TsuyaType.small)
        .copyWith(color: theme.colors.textMuted, fontFeatures: const [FontFeature.tabularFigures()]),
  );
}

Widget _list(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Section(
      label: 'Rows',
      children: [
        const ListItem(title: 'Listening history', onPressed: _noop),
        const ListItem(title: 'Downloads', subtitle: '38 albums · 2.4 GB', onPressed: _noop),
        ListItem(
          title: 'Playback quality',
          subtitle: 'Applies to this device',
          trailing: _value(context, 'High'),
          onPressed: _noop,
        ),
      ],
    ),
    Section(
      label: 'Leading and trailing',
      children: [
        ListItem(title: 'Equaliser', leading: const GIconView(GIcon.settings), navigates: true, onPressed: _noop),
        ListItem(
          title: covers[0].title,
          subtitle: covers[0].artist,
          leading: Thumbnail(image: covers[0].image, size: 48, label: covers[0].title),
          trailing: _value(context, '3:48'),
          onPressed: _noop,
        ),
        ListItem(
          title: 'Mira Vale',
          subtitle: 'mira@example.com',
          leading: const Avatar(initials: 'MV'),
          tall: true,
          navigates: true,
          onPressed: _noop,
        ),
      ],
    ),
    Section(
      label: 'Current, selected, disabled',
      children: [
        const ListItem(title: 'Library', current: true, onPressed: _noop),
        Hold<String>(
          initial: 'en',
          builder: (context, value, set) => Column(
            children: [
              ListItem(title: 'English', selected: value == 'en', onPressed: () => set('en')),
              ListItem(title: 'French', selected: value == 'fr', onPressed: () => set('fr')),
            ],
          ),
        ),
        const ListItem(title: 'Lyrics', subtitle: 'Not available offline'),
      ],
    ),
    const Section(
      label: 'Destructive, alone in the last group',
      children: [ListItem(title: 'Delete account', destructive: true, onPressed: _noop)],
    ),
    const Section(
      label: 'Long text ends with an ellipsis',
      children: [
        ListItem(
          title: 'A very long title that cannot possibly fit on a single line of a phone screen',
          subtitle: 'And a subtitle that is nearly as long, because people name their playlists like this',
          onPressed: _noop,
        ),
      ],
    ),
  ],
);

Widget _header(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Demo(
      'Page header',
      child: PageHeader(title: 'Albums', subtitle: '412 albums · 3 208 tracks'),
    ),
    Demo(
      'With actions, wrapping under the title when narrow',
      child: PageHeader(
        title: 'Playlists',
        subtitle: '24 playlists',
        actions: const Variants([
          IconButton(icon: Glyph(TsuyaGlyph.search), label: 'Search', onPressed: _noop),
          Button(label: 'New playlist', kind: ButtonKind.primary, onPressed: _noop),
        ]),
      ),
    ),
    const Demo(
      'Large',
      child: PageHeader(title: 'Good evening', subtitle: 'Pick up where you left off', large: true),
    ),
    const Demo(
      'Section header',
      child: Stacked([
        SectionHeader(title: 'Recently played', count: '12', actionLabel: 'See all', onAction: _noop),
        SectionHeader(title: 'Made for you'),
      ], gap: TsuyaSpace.s8),
    ),
  ],
);
