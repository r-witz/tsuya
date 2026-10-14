// The shape a control is drawn in (DESIGN.md, Button, IconButton, Chip): a fill with an optional hairline, or
// control glass over content. Shared by every action.
import 'package:flutter/widgets.dart';

import '../foundation/motion.dart';
import '../foundation/tokens.g.dart';
import '../material/glass.dart';

/// The drawn shape of a control (DESIGN.md, Button, IconButton, Chip): [fill] with an optional [border] hairline,
/// animated over [TsuyaDuration.fast], or control glass over content when [glass]. Shared by [Button], [IconButton]
/// and [Chip].
class ControlBody extends StatelessWidget {
  /// A shape around [child], clipped to [radius].
  const ControlBody({super.key, this.fill, this.border, required this.radius, this.glass = false, required this.child});

  /// The background colour, or null for none (a ghost button, a glass control).
  final Color? fill;

  /// The hairline colour, or null for none.
  final Color? border;

  /// The shape's corner radius.
  final BorderRadius radius;

  /// Control glass instead of [fill] and [border].
  final bool glass;

  /// The content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (glass) return ControlGlass(borderRadius: radius, child: child);
    return AnimatedContainer(
      duration: motionOf(context, TsuyaDuration.fast),
      curve: TsuyaEasing.standard,
      decoration: BoxDecoration(color: fill, borderRadius: radius),
      // The hairline is a foreground decoration, not the background one: `Container`/`AnimatedContainer` add a
      // bordered `decoration`'s width as implicit padding (Decoration.padding), inflating the control's natural
      // size by 2 * the border width regardless of `strokeAlign`; `foregroundDecoration` carries no such padding.
      foregroundDecoration: border == null
          ? null
          : BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: border!, strokeAlign: BorderSide.strokeAlignInside),
            ),
      child: child,
    );
  }
}
