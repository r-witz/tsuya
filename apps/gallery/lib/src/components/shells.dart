// 11.24 TabBar and Screen (the phone shell), 11.25 Sidebar (the desktop shell).
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/covers.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

void _noop() {}

/// The screens of the two shells.
final shellEntries = [
  GalleryEntry.component('tab-bar', 'TabBar', 'The phone shell: a floating tab bar over a scrolling screen.', _tabBar),
  GalleryEntry.component('sidebar', 'Sidebar', 'The desktop shell: groups of items, collapsible to icons.', _sidebar),
];

Widget _tabBar(BuildContext context) => Demo(
  'A screen with its dock, lit by the leading cover',
  child: ClipRRect(
    borderRadius: BorderRadius.circular(TsuyaRadius.md),
    child: SizedBox(height: 520, child: _MiniScreen()),
  ),
);

class _MiniScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Hold<String>(
    initial: 'library',
    builder: (context, tab, set) => Accent(
      pair: covers[1].accent,
      child: Screen(
        ambient: covers[1].image,
        dock: TabBar<String>(
          label: 'Main',
          current: tab,
          onSelect: set,
          items: const [
            TabBarItem(value: 'home', label: 'Home', icon: GIconView(GIcon.home, size: 24)),
            TabBarItem(value: 'library', label: 'Library', icon: GIconView(GIcon.library, size: 24)),
            TabBarItem(
              value: 'search',
              label: 'Search',
              icon: Glyph(TsuyaGlyph.search, size: 24),
              badge: TabBarBadge(dot: true, label: 'new'),
            ),
            TabBarItem(
              value: 'inbox',
              label: 'Inbox',
              icon: GIconView(GIcon.mail, size: 24),
              badge: TabBarBadge(count: 3, label: '3 new'),
            ),
          ],
        ),
        builder: (context, padding) => ListView(
          padding: padding.copyWith(top: TsuyaSpace.s24),
          children: [
            const PageHeader(title: 'Library', subtitle: '412 albums'),
            const SizedBox(height: TsuyaSpace.s16),
            for (final cover in covers)
              ListItem(
                title: cover.title,
                subtitle: cover.artist,
                leading: Thumbnail(image: cover.image, size: 48),
                onPressed: _noop,
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _sidebar(BuildContext context) => Demo(
  'Expanded, and collapsed to icons',
  child: Variants([
    _SidebarFrame(child: _items(collapsed: false)),
    _SidebarFrame(child: _items(collapsed: true)),
  ], spacing: TsuyaSpace.s16),
);

Widget _items({required bool collapsed}) => Hold<String>(
  initial: 'albums',
  builder: (context, current, set) => Sidebar(
    collapsed: collapsed,
    label: 'Library',
    children: [
      SidebarGroup(
        label: 'Library',
        children: [
          SidebarItem(
            icon: const GIconView(GIcon.album),
            label: 'Albums',
            count: 412,
            current: current == 'albums',
            onPressed: () => set('albums'),
          ),
          SidebarItem(
            icon: const GIconView(GIcon.user),
            label: 'Artists',
            count: 96,
            current: current == 'artists',
            onPressed: () => set('artists'),
          ),
          SidebarItem(
            icon: const GIconView(GIcon.heart),
            label: 'Favourites',
            current: current == 'favourites',
            onPressed: () => set('favourites'),
          ),
        ],
      ),
      SidebarGroup(
        label: 'Playlists',
        children: [
          SidebarItem(
            icon: const GIconView(GIcon.list),
            label: 'Morning',
            current: current == 'morning',
            onPressed: () => set('morning'),
          ),
          SidebarItem(
            icon: const GIconView(GIcon.list),
            label: 'Focus',
            current: current == 'focus',
            onPressed: () => set('focus'),
          ),
        ],
      ),
    ],
  ),
);

class _SidebarFrame extends StatelessWidget {
  const _SidebarFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: TsuyaTheme.of(context).colors.border),
      borderRadius: BorderRadius.circular(TsuyaRadius.md),
    ),
    child: child,
  );
}
