// How much of the bottom edge a floating dock takes (DESIGN.md, Toast, TabBar), for what floats above the page
// to clear it: a toast sits above the tab bar.
import 'package:flutter/widgets.dart';

import 'tokens.g.dart';

/// Tells what is shown from below it (a [Toast]) how much of the bottom edge a floating dock occupies, safe area
/// aside, so it can clear it: the dock's height plus the gap it floats at ([TsuyaSize.dock] + [TsuyaSpace.s12] for
/// the tab bar). A shell that has a dock provides it above its content; there is none (0) otherwise.
class DockInset extends InheritedWidget {
  /// Provides [height] to [child]'s descendants.
  const DockInset({super.key, required this.height, required super.child});

  /// The bottom edge the dock takes, in logical pixels.
  final double height;

  /// The inset provided at [context], or 0 when there is no dock.
  static double of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<DockInset>()?.height ?? 0;

  @override
  bool updateShouldNotify(DockInset oldWidget) => height != oldWidget.height;
}
