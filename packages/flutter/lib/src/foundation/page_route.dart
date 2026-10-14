// The fade of tsuya's pages (DESIGN.md, Theme and mode).
import 'package:flutter/widgets.dart';

import 'tokens.g.dart';

/// The fade tsuya's pages use: a [PageRouteBuilder] over [TsuyaDuration.base] with [TsuyaEasing.standard]. [TsuyaApp]
/// uses it for its own routes; use it as the `pageRouteBuilder` of a `WidgetsApp`, or in a router package's page
/// builder, to get the same transition.
class TsuyaPageRoute<T> extends PageRouteBuilder<T> {
  /// A page of [settings] showing what [builder] builds.
  TsuyaPageRoute({required RouteSettings settings, required WidgetBuilder builder})
    : super(
        settings: settings,
        transitionDuration: TsuyaDuration.base,
        reverseTransitionDuration: TsuyaDuration.base,
        pageBuilder: (context, _, _) => builder(context),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: TsuyaEasing.standard),
          child: child,
        ),
      );
}
