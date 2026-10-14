// The Flutter usage shown on the Sidebar page: read, not invented, from packages/flutter/lib/src/components/sidebar.dart.
export const FLUTTER_BASIC = `
Sidebar(
  label: 'Main',
  children: [
    SidebarGroup(
      label: 'Browse',
      children: [
        SidebarItem(
          icon: const HomeIcon(), // your own icon widget: tsuya ships no icon set
          label: 'Home',
          current: true,
          onPressed: () {},
        ),
        SidebarItem(
          icon: const LibraryIcon(),
          label: 'Library',
          count: 12,
          onPressed: () {},
        ),
      ],
    ),
  ],
)`.trim();
