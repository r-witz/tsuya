// The Flutter usage shown on the Badge page: read, not invented, from packages/flutter/lib/src/components/badge.dart and icon_button.dart.
export const FLUTTER_BASIC = `
IconButton(
  icon: const BellIcon(), // your own icon widget: tsuya ships no icon set
  label: 'Notifications, 3 unread',
  badge: const Badge.count(3),
  onPressed: () {
    // …
  },
)`.trim();

export const FLUTTER_DOT = `
const Badge.dot()`.trim();
