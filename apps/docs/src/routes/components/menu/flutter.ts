// The Flutter usage shown on the Menu page: read, not invented, from packages/flutter/lib/src/components/menu.dart and menu_button.dart.
export const FLUTTER_MENU_BUTTON = `
MenuButton(
  label: 'Actions',
  items: [
    MenuItem(label: 'Rename', shortcut: 'F2', onSelect: () {}),
    MenuItem(label: 'Share', onSelect: () {}),
    MenuItem(
      label: 'Show hidden files',
      checked: showHidden,
      onSelect: () => setState(() => showHidden = !showHidden),
    ),
    const MenuItem.separator(),
    const MenuItem.label('Sort by'),
    for (final (value, label) in [('title', 'Title'), ('artist', 'Artist')])
      MenuItem.radio(label: label, checked: sortBy == value, onSelect: () => setState(() => sortBy = value)),
    const MenuItem.separator(),
    MenuItem(label: 'Delete', destructive: true, onSelect: () {}),
  ],
)`.trim();

export const FLUTTER_SHOW = `
Builder(
  builder: (anchor) => IconButton(
    icon: const MoreIcon(), // your own icon widget: tsuya ships no icon set
    label: 'More actions',
    onPressed: () => Menu.show(
      anchor,
      items: [
        MenuItem(label: 'Rename', onSelect: () {}),
        MenuItem(label: 'Delete', destructive: true, onSelect: () {}),
      ],
    ),
  ),
)`.trim();
