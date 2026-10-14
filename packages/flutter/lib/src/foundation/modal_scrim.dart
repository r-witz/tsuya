// The scrim behind a modal overlay (DESIGN.md, Overlays and feedback). Shared by Dialog, Sheet and
// CommandPalette.
import 'package:flutter/widgets.dart';

import 'theme.dart';

/// A full-screen [TsuyaColors.scrim] that fades with [opacity]. With a [barrierLabel], it is also a button for a
/// screen reader that calls [onDismiss]; without one (a required decision, or no label given), it only dims.
/// Sighted presses on the scrim are the dismissable layer's own (it finds them by geometry), not this widget's.
class ModalScrim extends StatelessWidget {
  /// A scrim fading with [opacity].
  const ModalScrim({super.key, required this.opacity, this.barrierLabel, required this.onDismiss});

  /// How opaque it is, 0 to 1.
  final Animation<double> opacity;

  /// Names the scrim's dismiss action for a screen reader.
  final String? barrierLabel;

  /// Called when the labelled scrim is activated.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: FadeTransition(
      opacity: opacity,
      child: Semantics(
        button: barrierLabel != null,
        label: barrierLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: barrierLabel == null ? null : onDismiss,
          child: ColoredBox(color: TsuyaTheme.of(context).colors.scrim),
        ),
      ),
    ),
  );
}
