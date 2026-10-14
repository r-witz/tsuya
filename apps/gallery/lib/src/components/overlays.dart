// 11.26 Tooltip, 11.27 Menu, 11.28 Popover, 11.29 Dialog, 11.30 Sheet. What opens shows only when asked: each screen
// holds the buttons that open it and, where it helps, a line saying what was chosen.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import '../app/entry.dart';
import '../ui/demo.dart';
import '../ui/icons.dart';

void _noop() {}

/// The screens of the overlays that hold content.
final overlayEntries = [
  GalleryEntry.component(
    'tooltip',
    'Tooltip',
    'A short label for a control, on hover and focus, never on touch.',
    _tooltip,
  ),
  GalleryEntry.component('menu', 'Menu', 'Actions anchored to the control that opens them.', _menu),
  GalleryEntry.component('popover', 'Popover', 'A small panel of interactive content next to its trigger.', _popover),
  GalleryEntry.component('dialog', 'Dialog', 'A decision that needs an answer, or a short focused task.', _dialog),
  GalleryEntry.component('sheet', 'Sheet', 'Content that rises from the bottom, or comes from the side.', _sheet),
];

Widget _chosen(BuildContext context, String? what) {
  final theme = TsuyaTheme.of(context);
  return Padding(
    padding: const EdgeInsets.only(top: TsuyaSpace.s12),
    child: Text(
      what ?? 'Nothing chosen yet',
      style: theme.text(TsuyaType.small).copyWith(color: theme.colors.textMuted),
    ),
  );
}

Widget _tooltip(BuildContext context) => const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'On hover or keyboard focus, after a short delay',
      child: Variants([
        Tooltip(
          message: 'Add to favourites',
          child: IconButton(icon: GIconView(GIcon.heart), label: 'Add to favourites', tooltip: false, onPressed: _noop),
        ),
        Tooltip(
          message: 'Opens in a new window',
          side: AnchorSide.bottom,
          child: Button(label: 'Open player', onPressed: _noop),
        ),
      ]),
    ),
    Demo(
      'Icon buttons show their label by themselves',
      child: Variants([
        IconButton(icon: GIconView(GIcon.share), label: 'Share', onPressed: _noop),
        IconButton(icon: GIconView(GIcon.download), label: 'Download', onPressed: _noop),
      ]),
    ),
  ],
);

List<MenuItem> _menuItems(ValueChanged<String> pick) => [
  MenuItem(label: 'Play next', icon: const GIconView(GIcon.next), shortcut: 'N', onSelect: () => pick('Play next')),
  MenuItem(label: 'Add to playlist', icon: const GIconView(GIcon.plus), onSelect: () => pick('Add to playlist')),
  MenuItem(label: 'Download', icon: const GIconView(GIcon.download), disabled: true, onSelect: () => pick('Download')),
  MenuItem(label: 'Shuffle', checked: true, onSelect: () => pick('Shuffle')),
  const MenuItem.separator(),
  const MenuItem.label('Sort by'),
  MenuItem.radio(label: 'Title', checked: true, onSelect: () => pick('Sort by title')),
  MenuItem.radio(label: 'Artist', checked: false, onSelect: () => pick('Sort by artist')),
  const MenuItem.separator(),
  MenuItem(label: 'Remove', destructive: true, icon: const GIconView(GIcon.trash), onSelect: () => pick('Remove')),
];

Widget _menu(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'A menu button',
      child: Hold<String?>(
        initial: null,
        builder: (context, what, set) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuButton(icon: const GIconView(GIcon.more), label: 'More', items: _menuItems(set)),
            _chosen(context, what),
          ],
        ),
      ),
    ),
    Demo(
      'Opened from any control, with Menu.show',
      child: Hold<String?>(
        initial: null,
        builder: (context, what, set) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) => Button(
                label: 'Track options',
                onPressed: () => Menu.show(context, items: _menuItems(set), barrierLabel: 'Close menu'),
              ),
            ),
            _chosen(context, what),
          ],
        ),
      ),
    ),
  ],
);

Widget _popover(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'Filters',
      child: Variants([
        Popover(
          icon: const GIconView(GIcon.filter),
          label: 'Filters',
          builder: (context) => Hold<bool>(
            initial: true,
            builder: (context, on, set) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(value: on, onChanged: (v) => set(v!), label: 'Hide explicit tracks'),
                Checkbox(value: !on, onChanged: (v) => set(!v!), label: 'Only downloaded'),
              ],
            ),
          ),
        ),
      ]),
    ),
    Demo(
      'Aligned to the end, above the trigger',
      child: Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Popover(
          label: 'Details',
          side: AnchorSide.top,
          align: AnchorAlign.end,
          builder: (context) => const Text('Recorded in 2024 at the harbour studio.'),
        ),
      ),
    ),
  ],
);

Widget _dialog(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'A confirmation',
      child: Builder(
        builder: (context) => Button(
          label: 'Delete album',
          kind: ButtonKind.danger,
          onPressed: () => Dialog.show<void>(
            context,
            barrierLabel: 'Close dialog',
            builder: (dialog) => Dialog(
              title: 'Delete this album?',
              body: 'Its 11 tracks leave your library. You can add them again from the catalogue.',
              actions: [
                Button(label: 'Cancel', kind: ButtonKind.ghost, onPressed: () => Dialog.close<void>(dialog)),
                Button(label: 'Delete', kind: ButtonKind.danger, onPressed: () => Dialog.close<void>(dialog)),
              ],
            ),
          ),
        ),
      ),
    ),
    Demo(
      'A required decision, which Escape and the scrim do not close',
      child: Builder(
        builder: (context) => Button(
          label: 'Review terms',
          onPressed: () => Dialog.show<void>(
            context,
            dismissible: false,
            builder: (dialog) => Dialog(
              title: 'Terms have changed',
              body: 'Accept the new terms to keep listening offline.',
              alert: true,
              actions: [Button(label: 'Accept', kind: ButtonKind.primary, onPressed: () => Dialog.close<void>(dialog))],
            ),
          ),
        ),
      ),
    ),
    Demo(
      'A short task, large',
      child: Builder(
        builder: (context) => Button(
          label: 'New playlist',
          kind: ButtonKind.primary,
          onPressed: () => Dialog.show<void>(
            context,
            builder: (dialog) => Dialog(
              title: 'New playlist',
              size: DialogSize.lg,
              content: const TextField(label: 'Name', placeholder: 'Evening drive', autofocus: true),
              actions: [
                Button(label: 'Cancel', kind: ButtonKind.ghost, onPressed: () => Dialog.close<void>(dialog)),
                Button(label: 'Create', kind: ButtonKind.primary, onPressed: () => Dialog.close<void>(dialog)),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
);

Widget _sheetContent(BuildContext sheet) => Sheet(
  label: 'Add to playlist',
  child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Padding(
        padding: EdgeInsets.only(bottom: TsuyaSpace.s8),
        child: Text('Add to playlist', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      for (final name in const ['Morning', 'Focus', 'Evening drive'])
        ListItem(title: name, leading: const GIconView(GIcon.list), onPressed: () => Sheet.close<void>(sheet)),
    ],
  ),
);

Widget _sheet(BuildContext context) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Demo(
      'From the bottom: drag down, press Escape or the scrim to close',
      child: Builder(
        builder: (context) => Button(
          label: 'Add to playlist',
          icon: const GIconView(GIcon.plus),
          onPressed: () => Sheet.show<void>(context, barrierLabel: 'Close sheet', builder: _sheetContent),
        ),
      ),
    ),
    Demo(
      'From the end edge, for a desktop panel',
      child: Builder(
        builder: (context) => Button(
          label: 'Open the queue',
          onPressed: () => Sheet.show<void>(
            context,
            side: SheetSide.end,
            barrierLabel: 'Close queue',
            builder: (sheet) => Sheet(
              label: 'Queue',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ListItem(title: 'Slow Light', subtitle: 'Mira Vale'),
                  const ListItem(title: 'Low Tide', subtitle: 'The Harbour Club'),
                  Button(label: 'Close', onPressed: () => Sheet.close<void>(sheet)),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  ],
);
