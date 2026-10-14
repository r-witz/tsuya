// Which control opened an overlay, for focus to go back to it (DESIGN.md, Foundations: Accessibility).
// Used by Pressable (which reports the control being pressed) and showTsuyaOverlay (which asks).
import 'package:flutter/widgets.dart';

/// The focusable that opens whatever is shown right now. A press with a mouse or a finger does not move focus to the
/// control (as on a native button in some browsers), so the primary focus alone would miss it: a pressed
/// [Pressable] reports itself here for the length of its `onPressed`, and an overlay shown from it asks.
abstract final class OpenerFocus {
  static FocusNode? _pressed;

  /// Runs [onPressed] (a control's press) with [node] as the opener of anything shown during it.
  static void pressing(FocusNode? node, VoidCallback onPressed) {
    final before = _pressed;
    _pressed = node;
    try {
      onPressed();
    } finally {
      _pressed = before;
    }
  }

  /// The focusable that opens an overlay shown from [context] now: the control being pressed, else the one holding
  /// the primary focus, else the nearest one around [context].
  static FocusNode? of(BuildContext context) {
    final primary = FocusManager.instance.primaryFocus;
    return _pressed ??
        (primary is FocusScopeNode ? null : primary) ??
        Focus.maybeOf(context, scopeOk: false, createDependency: false);
  }
}
