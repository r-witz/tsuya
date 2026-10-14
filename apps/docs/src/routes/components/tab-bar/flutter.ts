// The Flutter usage shown on the TabBar page: read, not invented, from packages/flutter/lib/src/components/tab_bar.dart and screen.dart (the icons are your own widgets: tsuya ships no icon set).
export const FLUTTER_TAB_BAR = `
TabBar<String>(
  current: current,
  onSelect: (value) => setState(() => current = value),
  items: const [
    TabBarItem(value: 'home', label: 'Home', icon: HomeIcon()), // your own icon widgets: tsuya ships no icon set
    TabBarItem(
      value: 'inbox',
      label: 'Inbox',
      icon: InboxIcon(),
      badge: TabBarBadge(count: 3, label: '3 new'),
    ),
  ],
)`.trim();

export const FLUTTER_SCREEN = `
Screen(
  ambient: const AssetImage('assets/cover.png'),
  builder: (context, padding) => ListView(
    padding: padding,
    children: const [
      // …
    ],
  ),
  dock: TabBar<String>(
    current: current,
    onSelect: (value) => setState(() => current = value),
    items: items,
  ),
)`.trim();
