// Screen (DESIGN.md, TabBar, Screen).
// G7: text scale. G10: the keyboard. G13: spec values. G9, G14: smoke_test.dart.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';

import 'support.dart';

final _kTransparentImage = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

EdgeInsets? _lastPadding;

Widget _builder(BuildContext context, EdgeInsets padding) {
  _lastPadding = padding;
  return ListView(
    padding: padding,
    children: [for (var i = 0; i < 30; i++) SizedBox(height: 40, child: Text('Row $i'))],
  );
}

/// Overrides the ambient [MediaQuery]'s safe-area padding and keyboard inset for a test, without touching `host`'s
/// own (shared by every other test file).
Widget _insets(Widget child, {EdgeInsets padding = EdgeInsets.zero, EdgeInsets viewInsets = EdgeInsets.zero}) =>
    Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(padding: padding, viewInsets: viewInsets),
        child: child,
      ),
    );

Widget _screen({Widget? dock}) => host(
  Screen(
    dock: dock,
    builder: (context, padding) => ListView(
      padding: padding,
      children: [
        Button(
          label: 'Show',
          onPressed: () => unawaited(Toast.show(context, message: 'Saved')),
        ),
      ],
    ),
  ),
  size: const Size(800, 600),
);

Rect _toast(WidgetTester tester) => tester.getRect(find.ancestor(of: find.text('Saved'), matching: find.byType(Glass)));

Future<void> _show(WidgetTester tester) async {
  await tester.tap(find.text('Show'));
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('wires ambient and grain to its surface; the glow lights the top without one', (tester) async {
    await tester.pumpWidget(host(Screen(builder: _builder), size: const Size(390, 700)));
    expect(find.byType(Glow), findsOneWidget);
    expect(find.byType(Ambient), findsNothing);

    await tester.pumpWidget(
      host(
        Screen(ambient: MemoryImage(_kTransparentImage), builder: _builder),
        size: const Size(390, 700),
      ),
    );
    expect(find.byType(Ambient), findsOneWidget);
    expect(find.byType(Glow), findsNothing);
  });

  testWidgets('the content is padded for the side margins and the safe areas', (tester) async {
    await tester.pumpWidget(
      host(
        _insets(Screen(builder: _builder), padding: const EdgeInsets.fromLTRB(5, 40, 5, 20)),
        size: const Size(390, 700),
      ),
    );
    expect(_lastPadding!.left, TsuyaSpace.s20 + 5);
    expect(_lastPadding!.right, TsuyaSpace.s20 + 5);
    expect(_lastPadding!.top, 40);
    expect(_lastPadding!.bottom, 20 + TsuyaSpace.s24);
  });

  testWidgets('the dock floats 12 from the edges above the bottom; the content fades into bg under it', (tester) async {
    final dockKey = GlobalKey();
    await tester.pumpWidget(
      host(
        Screen(
          builder: _builder,
          dock: SizedBox(key: dockKey, height: 66),
        ),
        size: const Size(390, 700),
      ),
    );
    final screen = tester.getRect(find.byType(Screen));
    final dock = tester.getRect(find.byKey(dockKey));
    expect(dock.left - screen.left, TsuyaSpace.s12);
    expect(screen.right - dock.right, TsuyaSpace.s12);
    expect(screen.bottom - dock.bottom, TsuyaSpace.s12);
    final gradient =
        tester
                .widgetList<DecoratedBox>(find.descendant(of: find.byType(Screen), matching: find.byType(DecoratedBox)))
                .map((b) => b.decoration)
                .whereType<BoxDecoration>()
                .where((d) => d.gradient != null)
                .single
                .gradient!
            as LinearGradient;
    expect(gradient.colors.last, TsuyaColors.light.bg);
  });

  testWidgets('with a dock, the padding also reserves room so the content clears it', (tester) async {
    await tester.pumpWidget(
      host(
        Screen(builder: _builder, dock: const SizedBox(height: 66)),
        size: const Size(390, 700),
      ),
    );
    expect(_lastPadding!.bottom, TsuyaSpace.s24 + TsuyaSpace.s12 + TsuyaSize.dock);
  });

  testWidgets('G7: the padding follows the dock\'s real height, in the frame the dock changes', (tester) async {
    Widget screen(double dockHeight) => host(
      Screen(
        builder: _builder,
        dock: SizedBox(height: dockHeight),
      ),
      size: const Size(390, 700),
    );
    await tester.pumpWidget(screen(66));
    expect(_lastPadding!.bottom, closeTo(TsuyaSpace.s24 + TsuyaSpace.s12 + 66, 0.01));
    await tester.pumpWidget(screen(200));
    expect(_lastPadding!.bottom, closeTo(TsuyaSpace.s24 + TsuyaSpace.s12 + 200, 0.01));
  });

  testWidgets('G7: at 300 %, the last row rests clear of the tab bar', (tester) async {
    await tester.pumpWidget(
      host(
        Screen(
          builder: _builder,
          dock: TabBar<String>(
            items: [
              for (final name in ['Home', 'Search', 'Library'])
                TabBarItem(value: name, label: name, icon: const Glyph(TsuyaGlyph.back)),
            ],
            current: 'Home',
            onSelect: (_) {},
          ),
        ),
        size: const Size(390, 700),
        textScale: 3,
      ),
    );
    expect(tester.takeException(), isNull);
    final position = tester.state<ScrollableState>(find.byType(Scrollable)).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
    final dock = tester.getRect(find.byType(TabBar<String>));
    expect(dock.height, greaterThan(TsuyaSize.dock));
    expect(tester.getRect(find.text('Row 29')).bottom, lessThanOrEqualTo(dock.top));
  });

  testWidgets('G10: the content shrinks by the keyboard inset, so a focused field can scroll above it', (tester) async {
    await tester.pumpWidget(
      host(
        _insets(Screen(builder: _builder), viewInsets: const EdgeInsets.only(bottom: 280)),
        size: const Size(390, 700),
      ),
    );
    final screen = tester.getRect(find.byType(Screen));
    final content = tester.getRect(find.byType(ListView));
    expect(screen.height - content.height, 280);
  });

  testWidgets('the fade spans the screen width down to its bottom edge, whatever the dock margins', (tester) async {
    final dockKey = GlobalKey();
    await tester.pumpWidget(
      host(
        _insets(
          Screen(
            builder: _builder,
            dock: SizedBox(key: dockKey, height: 66),
          ),
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 20),
        ),
        size: const Size(390, 700),
      ),
    );
    final screen = tester.getRect(find.byType(Screen));
    final fade = tester
        .widgetList<DecoratedBox>(find.descendant(of: find.byType(Screen), matching: find.byType(DecoratedBox)))
        .where((b) => b.decoration is BoxDecoration && (b.decoration as BoxDecoration).gradient != null)
        .single;
    final fadeRect = tester.getRect(find.byWidget(fade));
    expect(fadeRect.left, screen.left);
    expect(fadeRect.right, screen.right);
    expect(fadeRect.bottom, screen.bottom);
    final dock = tester.getRect(find.byKey(dockKey));
    expect(dock.left - screen.left, TsuyaSpace.s12 + 8);
    expect(screen.right - dock.right, TsuyaSpace.s12 + 16);
    expect(screen.bottom - dock.bottom, TsuyaSpace.s12 + 20);
    expect(fadeRect.top, closeTo(dock.top - TsuyaSpace.s24, 0.01));
  });

  testWidgets('on a desktop platform, a press on the current tab still scrolls the content to the top', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await tester.pumpWidget(
        host(
          Screen(
            builder: _builder,
            dock: TabBar<String>(
              items: [TabBarItem(value: 'home', label: 'Home', icon: const Glyph(TsuyaGlyph.back))],
              current: 'home',
              onSelect: (_) {},
            ),
          ),
          size: const Size(390, 700),
        ),
      );
      final position = tester.state<ScrollableState>(find.byType(Scrollable)).position;
      position.jumpTo(300);
      await tester.pump();
      expect(position.pixels, 300);
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(position.pixels, 0);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  // Screen and Toast (DESIGN.md, TabBar, Toast, Screen): a toast shown from inside clears the dock.
  // G13: spec values.
  testWidgets('a toast shown from inside a Screen with a tab bar sits above the bar', (tester) async {
    await tester.pumpWidget(
      _screen(
        dock: TabBar<String>(
          items: [TabBarItem(value: 'home', label: 'Home', icon: const Glyph(TsuyaGlyph.back))],
          current: 'home',
          onSelect: (_) {},
        ),
      ),
    );
    await _show(tester);
    final bar = tester.getRect(find.byType(TabBar<String>));
    expect(_toast(tester).bottom, lessThanOrEqualTo(bar.top - TsuyaSpace.s16));
    expect(_toast(tester).bottom, moreOrLessEquals(600 - TsuyaSpace.s16 - TsuyaSize.dock - TsuyaSpace.s12));
  });

  testWidgets('without a dock, a toast shown from a Screen keeps its usual place', (tester) async {
    await tester.pumpWidget(_screen());
    await _show(tester);
    expect(_toast(tester).bottom, 600 - TsuyaSpace.s16);
  });
}
