// Announcing a change to screen readers without a visible live region (DESIGN.md, Foundations: Accessibility).
// Used by the toast, combobox results and other async states.
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Announces [message] to the screen reader active at [context]: politely by default, or [assertive] to interrupt
/// what it is currently saying (sparingly, for urgent changes).
void announce(BuildContext context, String message, {bool assertive = false}) {
  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
    assertiveness: assertive ? Assertiveness.assertive : Assertiveness.polite,
  );
}
