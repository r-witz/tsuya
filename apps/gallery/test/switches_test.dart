// The switches of the gallery change what they say they change.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';
import 'package:tsuya_gallery/src/app/settings.dart';
import 'package:tsuya_gallery/src/app/shell.dart';

import 'support.dart';

// the phone gallery, on its Controls tab
Future<GalleryController> _controls(WidgetTester tester, {Size size = phone, GallerySettings? settings}) async {
  setScreen(tester, size);
  final controller = await pumpHome(
    tester,
    const GalleryShell(),
    settings: settings ?? const GallerySettings(mode: TsuyaMode.light, reduceMotion: true),
  );
  // on a desktop the switches are always there
  if (size.width < TsuyaBreakpoint.desktop) await _tap(tester, 'Controls');
  return controller;
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pump(const Duration(milliseconds: 50));
}

BuildContext _probe(WidgetTester tester) => tester.element(find.byType(PageHeader).first);

void main() {
  testWidgets('mode flips the theme of the whole app', (tester) async {
    await _controls(tester);
    expect(TsuyaTheme.of(_probe(tester)).isDark, isFalse);
    await _tap(tester, 'Dark');
    expect(TsuyaTheme.of(_probe(tester)).isDark, isTrue);
    await _tap(tester, 'Light');
    expect(TsuyaTheme.of(_probe(tester)).isDark, isFalse);
  });

  testWidgets('mode System follows the platform brightness', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _controls(tester, settings: const GallerySettings(mode: TsuyaMode.light, reduceMotion: true));
    await _tap(tester, 'Auto');
    expect(TsuyaTheme.of(_probe(tester)).isDark, isTrue);
  });

  testWidgets('accent reaches the components through the package accent API', (tester) async {
    final controller = await _controls(tester);
    expect(Accent.of(_probe(tester)), TsuyaColors.light.accent);
    await _tap(tester, 'Violet');
    await tester.pump(const Duration(seconds: 1));
    expect(controller.value.accentChoice.name, 'Violet');
    expect(Accent.of(_probe(tester)), accentFromColor('#8B5CF6').light);
  });

  testWidgets('text scale reaches the components', (tester) async {
    await _controls(tester);
    final before = tester.getSize(find.text('Controls').first).height;
    await _tap(tester, '2×');
    expect(MediaQuery.textScalerOf(_probe(tester)).scale(10), 20);
    expect(tester.getSize(find.text('Controls').first).height, greaterThan(before * 1.8));
  });

  testWidgets('direction flips the layout', (tester) async {
    await _controls(tester);
    expect(Directionality.of(_probe(tester)), TextDirection.ltr);
    final left = tester.getTopLeft(find.text('Controls').first).dx;
    expect(left, lessThan(100));
    await _tap(tester, 'RTL');
    expect(Directionality.of(_probe(tester)), TextDirection.rtl);
    expect(tester.getTopRight(find.text('Controls').first).dx, greaterThan(300));
  });

  testWidgets('reduced transparency, reduced motion and high contrast reach the package', (tester) async {
    await _controls(tester, settings: const GallerySettings(mode: TsuyaMode.light));
    expect(MediaQuery.disableAnimationsOf(_probe(tester)), isFalse);
    expect(GlassScope.of(_probe(tester)).reduce, isFalse);
    await _tap(tester, 'Reduce transparency');
    expect(GlassScope.of(_probe(tester)).reduce, isTrue);
    await _tap(tester, 'Reduce transparency');
    expect(GlassScope.of(_probe(tester)).reduce, isFalse);
    await _tap(tester, 'High contrast');
    expect(MediaQuery.highContrastOf(_probe(tester)), isTrue);
    expect(GlassScope.of(_probe(tester)).reduce, isTrue);
    await _tap(tester, 'Reduce motion');
    expect(MediaQuery.disableAnimationsOf(_probe(tester)), isTrue);
  });

  testWidgets('a phone shows tabs and pushes a screen under a screen bar', (tester) async {
    await _controls(tester);
    expect(find.byType(TabBar<Object?>), findsNothing);
    await _tap(tester, 'Components');
    await _tap(tester, 'Button');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ScreenBar), findsOneWidget);
    await tester.tap(find.byWidgetPredicate((w) => w is Glyph && w.glyph == TsuyaGlyph.back));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ScreenBar), findsNothing);
  });

  testWidgets('a desktop shows the sidebar and the switches beside the screen', (tester) async {
    await _controls(tester, size: desktop);
    expect(find.byType(Sidebar), findsOneWidget);
    expect(find.byType(ScreenBar), findsNothing);
    await _tap(tester, 'Dark');
    expect(TsuyaTheme.of(_probe(tester)).isDark, isTrue);
    await _tap(tester, 'Banner');
    expect(find.textContaining('A lasting state'), findsWidgets);
  });
}
