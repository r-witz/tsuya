// Carrying tsuya's scopes into an overlay built elsewhere in the tree (DESIGN.md, Foundations: Theme and mode).
// Used by every overlay (menus, popovers, dialogs, sheets, toasts…).
import 'package:flutter/widgets.dart';

/// An `Overlay` route is built where the `Navigator` lives, not where it was opened, so by default it falls back
/// to the theme, accent, glass scope and labels at the navigator's position instead of the opener's. `TsuyaTheme`,
/// `Accent`, `GlassScope` and `TsuyaLabelsScope` are all `InheritedTheme`s for exactly this: [wrap] carries them
/// (and any other `InheritedTheme`, such as `DefaultTextStyle` or `IconTheme`) from where the overlay opens to
/// where it is shown.
abstract final class TsuyaPortal {
  /// [child] wrapped in the tsuya scopes (and other `InheritedTheme`s) found between [from] and [to] — the root of
  /// the tree when [to] is omitted. Call this with the context that opens the overlay, before pushing it, and use
  /// the result as the overlay's content.
  static Widget wrap({required BuildContext from, required Widget child, BuildContext? to}) =>
      InheritedTheme.captureAll(from, child, to: to);

  /// The same scopes, read now and wrapped later: for an overlay whose builder reruns for as long as it is shown,
  /// where [wrap] would look them up again from [from], which may be gone by then.
  static CapturedThemes capture({required BuildContext from, BuildContext? to}) =>
      InheritedTheme.capture(from: from, to: to);
}
