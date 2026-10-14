// The Flutter usage shown on the List page: read, not invented, from packages/flutter/lib/src/components/list_item.dart and section.dart.
export const FLUTTER_LIST_ITEM = `
ListItem(
  title: 'Wi-Fi',
  subtitle: 'Home network',
  navigates: true,
  onPressed: () {
    // …
  },
)`.trim();

export const FLUTTER_SECTION = `
Section(
  label: 'General',
  children: [
    ListItem(title: 'Notifications', onPressed: () {}),
    ListItem(title: 'Language', subtitle: 'English', onPressed: () {}),
  ],
)`.trim();
