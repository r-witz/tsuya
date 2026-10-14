// Shared helpers: the gallery on a phone or a desktop screen, with pictures decoded and the grain drawn.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tsuya/tsuya.dart';
import 'package:tsuya_gallery/src/app/entry.dart';
import 'package:tsuya_gallery/src/app/host.dart';
import 'package:tsuya_gallery/src/app/settings.dart';

/// A phone screen.
const phone = Size(390, 844);

/// A desktop screen.
const desktop = Size(1440, 900);

/// Puts [tester]'s view at [size] with one device pixel per logical one, so a golden is a screen at 1×.
void setScreen(WidgetTester tester, Size size) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
}

/// Shows [home] in the gallery host with [settings] (animations off by default: golden tests must not move) and waits
/// for what loads in real time: pictures and the grain tile. Returns the controller, to change a switch.
Future<GalleryController> pumpHome(
  WidgetTester tester,
  Widget home, {
  GallerySettings settings = const GallerySettings(mode: TsuyaMode.light, reduceMotion: true),
}) async {
  final controller = GalleryController(settings);
  await tester.pumpWidget(GalleryHost(controller: controller, home: home));
  await settle(tester);
  return controller;
}

/// [entry]'s body on a screen of [size]; a page of variants is shown whole, the screen as tall as its content.
Future<GalleryController> pumpEntry(
  WidgetTester tester,
  GalleryEntry entry, {
  Size size = phone,
  GallerySettings settings = const GallerySettings(mode: TsuyaMode.light, reduceMotion: true),
  bool whole = false,
}) async {
  setScreen(tester, size);
  final controller = await pumpHome(tester, EntryBody(entry), settings: settings);
  if (whole && !entry.isBlock) {
    final extent = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .where((s) => s.axisDirection == AxisDirection.down)
        .fold(0.0, (most, s) => s.position.maxScrollExtent > most ? s.position.maxScrollExtent : most);
    if (extent > 0) {
      tester.view.physicalSize = Size(size.width, size.height + extent.ceilToDouble());
      await settle(tester);
    }
  }
  return controller;
}

/// Lets the route in, decodes every picture on screen and waits for the grain tile to be drawn.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  for (var round = 0; round < 2; round++) {
    await tester.runAsync(() async {
      for (final image in tester.widgetList<Image>(find.byType(Image)).toList()) {
        await precacheImage(image.image, tester.element(find.byWidget(image)));
      }
    });
    await tester.pump();
  }
  for (var i = 0; i < 40 && _grainPending(tester); i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump();
  }
}

// a Grain draws once its tile has decoded on an engine thread; under high contrast it draws nothing at all
bool _grainPending(WidgetTester tester) => tester
    .elementList(find.byType(Grain))
    .any(
      (grain) =>
          !(MediaQuery.maybeHighContrastOf(grain) ?? false) &&
          find.descendant(of: find.byWidget(grain.widget), matching: find.byType(CustomPaint)).evaluate().isEmpty,
    );

/// Runs [body] with shadows drawn as the tokens say: the test binding draws them without blur by default, and they
/// are part of what a golden shows. The binding insists the flag is back to its default when the test ends.
Future<void> withShadows(Future<void> Function() body) async {
  debugDisableShadows = false;
  try {
    await body();
  } finally {
    debugDisableShadows = true;
  }
}
