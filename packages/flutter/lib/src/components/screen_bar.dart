// The bar of a pushed screen (DESIGN.md, TopBar, ScreenBar).
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'glyphs.dart';
import 'icon_button.dart';

/// The bar of a pushed screen (DESIGN.md, ScreenBar): at least [TsuyaSize.bar] tall; a round back button named
/// [backLabel] at the start (required together with [onBack]); [title] centred in [TsuyaType.titleM], one line
/// with an ellipsis, an optional [subtitle] caption below it; at most one [action] at the end.
class ScreenBar extends StatelessWidget {
  /// A bar headed [title], with [subtitle], [onBack] (named [backLabel]) and [action].
  const ScreenBar({super.key, required this.title, this.subtitle, this.onBack, this.backLabel, this.action})
    : assert((onBack == null) == (backLabel == null), 'backLabel is required together with onBack');

  /// The bar's title, centred on one line.
  final String title;

  /// A caption line under the title.
  final String? subtitle;

  /// Called when the back button is pressed; without it, there is no back button.
  final VoidCallback? onBack;

  /// The back button's accessible name; required together with [onBack].
  final String? backLabel;

  /// One action at the end.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final onBack = this.onBack;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TsuyaSize.bar),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The grid of the web bar: the title takes its own width up to what leaves each side its minimum; the
          // sides share the rest equally, so the title stays centred.
          final titleMax = (constraints.maxWidth - 2 * TsuyaSize.controlMd - 2 * TsuyaSpace.s8).clamp(
            0.0,
            double.infinity,
          );
          return Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: onBack == null
                      ? null
                      : IconButton(icon: const Glyph(TsuyaGlyph.back), label: backLabel!, onPressed: onBack),
                ),
              ),
              const SizedBox(width: TsuyaSpace.s8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: titleMax),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      container: true,
                      headingLevel: 1,
                      label: title,
                      child: ExcludeSemantics(
                        child: Text(
                          title,
                          style: theme.text(TsuyaType.titleM).copyWith(color: colors.text),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.text(TsuyaType.caption).copyWith(color: colors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: TsuyaSpace.s8),
              Expanded(
                child: Align(alignment: AlignmentDirectional.centerEnd, child: action),
              ),
            ],
          );
        },
      ),
    );
  }
}
