// A phone app on tsuya: the app root, a screen with a tab bar, a list, a dialog, a toast, and an accent taken from
// an image. Run it with `flutter run` after `flutter create .` has added the platform folders you need.
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart' hide Banner, RadioGroup;
import 'package:tsuya/tsuya.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  // With no `labels`, tsuya's own strings follow the locale (French or English).
  @override
  Widget build(BuildContext context) => const TsuyaApp(title: 'tsuya example', home: Home());
}

enum Tab { lists, about }

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Tab _tab = Tab.lists;
  MemoryImage? _cover;
  AccentPair _accent = AccentPair.neutral;

  @override
  void initState() {
    super.initState();
    _loadCover();
  }

  // The accent comes from the picture that leads the screen: here a generated one.
  Future<void> _loadCover() async {
    final cover = await generatedCover();
    final accent = await accentFromImage(cover);
    if (!mounted) return;
    setState(() {
      _cover = cover;
      _accent = accent;
    });
  }

  @override
  Widget build(BuildContext context) => Accent(
    pair: _accent,
    child: Screen(
      ambient: _cover,
      builder: (context, padding) => switch (_tab) {
        Tab.lists => Lists(padding: padding),
        Tab.about => About(padding: padding),
      },
      dock: TabBar<Tab>(
        current: _tab,
        onSelect: (tab) => setState(() => _tab = tab),
        items: const [
          TabBarItem(value: Tab.lists, label: 'Lists', icon: Glyph(TsuyaGlyph.menu)),
          TabBarItem(value: Tab.about, label: 'About', icon: Glyph(TsuyaGlyph.info)),
        ],
      ),
    ),
  );
}

class Lists extends StatelessWidget {
  const Lists({super.key, required this.padding});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => ListView(
    padding: padding,
    children: [
      const PageHeader(title: 'Lists'),
      Section(
        label: 'Fruit',
        children: [
          for (final fruit in const ['Apple', 'Pear', 'Plum'])
            ListItem(
              title: fruit,
              navigates: true,
              onPressed: () => Toast.show(context, message: '$fruit picked'),
            ),
        ],
      ),
    ],
  );
}

class About extends StatelessWidget {
  const About({super.key, required this.padding});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext page) => ListView(
    padding: padding,
    children: [
      const PageHeader(title: 'About'),
      Button(
        label: 'Delete everything',
        onPressed: () => Dialog.show<void>(
          page,
          builder: (context) => Dialog(
            title: 'Delete everything?',
            body: 'This cannot be undone.',
            actions: [
              Button(label: 'Cancel', kind: ButtonKind.ghost, onPressed: () => Dialog.close(context)),
              Button(
                label: 'Delete',
                kind: ButtonKind.primary,
                onPressed: () {
                  Dialog.close(context);
                  Toast.show(page, message: 'Deleted');
                },
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

/// A 64 by 64 picture, warm at the top and teal at the bottom.
Future<MemoryImage> generatedCover() async {
  const side = 64.0;
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const Rect.fromLTWH(0, 0, side, side),
    ui.Paint()
      ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, side), const [Color(0xFFE8734A), Color(0xFF1F8A8A)]),
  );
  final image = await recorder.endRecording().toImage(side.toInt(), side.toInt());
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(png!.buffer.asUint8List());
}
