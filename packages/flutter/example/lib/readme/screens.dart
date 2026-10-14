// The README's Screen, accent and overlay snippets, compiled here so they cannot rot (see test/readme_test.dart).
import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

enum Tab { inbox, settings }

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  Tab _tab = Tab.inbox;

  @override
  Widget build(BuildContext context) => Screen(
    builder: (context, padding) => ListView(
      padding: padding,
      children: [PageHeader(title: _tab.name)],
    ),
    dock: TabBar<Tab>(
      current: _tab,
      onSelect: (tab) => setState(() => _tab = tab),
      items: const [
        TabBarItem(value: Tab.inbox, label: 'Inbox', icon: Glyph(TsuyaGlyph.menu)),
        TabBarItem(value: Tab.settings, label: 'Settings', icon: Glyph(TsuyaGlyph.info)),
      ],
    ),
  );
}

class Cover extends StatefulWidget {
  const Cover({super.key, required this.image});

  final ImageProvider image;

  @override
  State<Cover> createState() => _CoverState();
}

class _CoverState extends State<Cover> {
  AccentPair _accent = AccentPair.neutral;

  @override
  void initState() {
    super.initState();
    accentFromImage(widget.image).then((pair) {
      if (mounted) setState(() => _accent = pair);
    });
  }

  @override
  Widget build(BuildContext context) => Accent(
    pair: _accent,
    child: Screen(
      ambient: widget.image,
      builder: (context, padding) => ListView(padding: padding),
    ),
  );
}

Future<void> askToDelete(BuildContext context) async {
  final confirmed = await Dialog.show<bool>(
    context,
    builder: (context) => Dialog(
      title: 'Delete photo?',
      body: 'This cannot be undone.',
      actions: [
        Button(label: 'Cancel', kind: ButtonKind.ghost, onPressed: () => Dialog.close(context, false)),
        Button(label: 'Delete', kind: ButtonKind.danger, onPressed: () => Dialog.close(context, true)),
      ],
    ),
  );
  if (confirmed == true && context.mounted) Toast.show(context, message: 'Photo deleted');
}

Future<void> openFilters(BuildContext context) => Sheet.show<void>(
  context,
  builder: (context) => const Sheet(label: 'Filters', child: Text('Filters go here')),
);
