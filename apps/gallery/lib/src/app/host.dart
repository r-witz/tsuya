// The app root: a WidgetsApp with tsuya in its builder (DESIGN.md, Using tsuya: an app that keeps its own app widget
// puts TsuyaScope there), so the switches can reach above the Navigator and change what menus, dialogs and sheets
// show too.
import 'package:flutter/widgets.dart';
import 'package:tsuya/tsuya.dart';

import 'settings.dart';

/// A route that fades in over [TsuyaDuration.base], as `TsuyaApp`'s do. This app cannot use `TsuyaApp`: the switches
/// have to wrap its `Navigator`, so that what menus, dialogs and sheets open follows them.
PageRoute<T> fadeRoute<T>(RouteSettings settings, WidgetBuilder builder) => PageRouteBuilder<T>(
  settings: settings,
  transitionDuration: TsuyaDuration.base,
  reverseTransitionDuration: TsuyaDuration.base,
  pageBuilder: (context, _, _) => builder(context),
  transitionsBuilder: (context, animation, _, child) => FadeTransition(
    opacity: CurvedAnimation(parent: animation, curve: TsuyaEasing.standard),
    child: child,
  ),
);

/// Applies the switches of [controller] to [home] and everything the app pushes or opens above it: the mode, the
/// accent, the text scale, the direction and what the platform would say about transparency, motion and contrast.
class GalleryHost extends StatelessWidget {
  /// An app showing [home].
  const GalleryHost({super.key, required this.controller, required this.home});

  /// The switches.
  final GalleryController controller;

  /// The first screen.
  final Widget home;

  @override
  Widget build(BuildContext context) => GalleryScope(
    controller: controller,
    child: ListenableBuilder(
      listenable: controller,
      builder: (context, _) => WidgetsApp(
        title: 'tsuya gallery',
        debugShowCheckedModeBanner: false,
        color: TsuyaColors.light.accent,
        home: home,
        builder: (context, child) => _Frame(settings: controller.value, child: child!),
        pageRouteBuilder: fadeRoute,
      ),
    ),
  );
}

class _Frame extends StatelessWidget {
  const _Frame({required this.settings, required this.child});

  final GallerySettings settings;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(settings.textScale),
        highContrast: media.highContrast || settings.highContrast,
        disableAnimations: media.disableAnimations || settings.reduceMotion,
      ),
      child: Directionality(
        textDirection: settings.rtl ? TextDirection.rtl : TextDirection.ltr,
        child: TsuyaScope(
          mode: settings.mode,
          labels: TsuyaLabels.en,
          child: Accent(
            pair: settings.accentChoice.pair,
            child: GlassScope(reduce: settings.reduceTransparency, child: child),
          ),
        ),
      ),
    );
  }
}
