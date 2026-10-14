// A small count or dot, pinned on a host's corner (DESIGN.md, Badge).
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import '../material/accent.dart';

// DESIGN.md, Badge: the count pill's height.
const _countHeight = 18.0;
// DESIGN.md, Badge: the count pill's side padding.
const _countPadding = 5.0;
// DESIGN.md, Badge: "99+" above this.
const _countMax = 99;
// DESIGN.md, Badge: the dot's diameter.
const _dotSize = 8.0;
// DESIGN.md, Badge: the pin pokes 30 % of its own size past the host's corner.
const _pinOffset = 0.3;

/// A badge (DESIGN.md, Badge): a [Badge.count] pill ("99+" above 99) or a [Badge.dot], meant to be pinned on a
/// host's corner through its `badge:` slot (see [pinBadge], used by [IconButton] and [Avatar]). Always decorative:
/// its meaning belongs to the host's accessible name, not to the badge itself.
class Badge extends StatelessWidget {
  /// A pill showing [count], "99+" above 99.
  const Badge.count(this.count, {super.key});

  /// An 8 px dot.
  const Badge.dot({super.key}) : count = null;

  /// Shown as text, "99+" above 99; null for a dot.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final accent = Accent.of(context);
    final count = this.count;
    final Widget content = count == null
        ? SizedBox(
            width: _dotSize,
            height: _dotSize,
            child: DecoratedBox(
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          )
        : DecoratedBox(
            decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(TsuyaRadius.full)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _countHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: _countPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      count > _countMax ? '$_countMax+' : '$count',
                      style: theme
                          .text(TsuyaType.micro)
                          .copyWith(fontWeight: FontWeight.w700, color: theme.colors.onAccent),
                    ),
                  ],
                ),
              ),
            ),
          );
    return ExcludeSemantics(child: content);
  }
}

/// Pins [badge] (if any) on the top-end corner of [host], [_pinOffset] of its own size past it (DESIGN.md, Badge),
/// mirrored right-to-left; the pin ignores pointer events, so a press still reaches [host].
Widget pinBadge(BuildContext context, Widget host, Widget? badge) {
  if (badge == null) return host;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  return Stack(
    clipBehavior: Clip.none,
    children: [
      host,
      PositionedDirectional(
        top: 0,
        end: 0,
        child: IgnorePointer(
          child: FractionalTranslation(translation: Offset(rtl ? -_pinOffset : _pinOffset, -_pinOffset), child: badge),
        ),
      ),
    ],
  );
}
