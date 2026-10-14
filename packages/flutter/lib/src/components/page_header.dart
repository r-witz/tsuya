// A page's header (DESIGN.md, PageHeader, SectionHeader).
// Text scale (the title wraps rather than clipping).
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';

/// A page's header (DESIGN.md, PageHeader): a large left-aligned [title], a count line ([subtitle]) 8 below it,
/// and [actions] at the end that wrap under the title when the header is narrow. The title grows from
/// [TsuyaType.displayS] (phone) to [TsuyaType.displayM] from the desktop breakpoint, or to [TsuyaType.displayL]
/// when [large].
class PageHeader extends StatelessWidget {
  /// A header titled [title].
  const PageHeader({super.key, required this.title, this.subtitle, this.large = false, this.actions});

  /// The page's title.
  final String title;

  /// The count line below the title ("412 albums · 3 208 tracks").
  final String? subtitle;

  /// The title reaches [TsuyaType.displayL] from the desktop breakpoint, for a page that opens on it.
  final bool large;

  /// Shown at the end, wrapping under the title when narrow.
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    // the header's own width, as the web's container query reads it (DESIGN.md, Layout: breakpoints are the
    // container's, not the device's)
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= TsuyaBreakpoint.desktop;
        final titleStyle = desktop ? (large ? TsuyaType.displayL : TsuyaType.displayM) : TsuyaType.displayS;
        return _layout(theme, colors, titleStyle);
      },
    );
  }

  Widget _layout(TsuyaThemeData theme, TsuyaColors colors, TextStyle titleStyle) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: TsuyaSpace.s16,
      runSpacing: TsuyaSpace.s16,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              container: true,
              headingLevel: 1,
              child: Text(title, style: theme.text(titleStyle).copyWith(color: colors.text)),
            ),
            if (subtitle case final subtitle?) ...[
              const SizedBox(height: TsuyaSpace.s8),
              Text(subtitle, style: theme.text(TsuyaType.small).copyWith(color: colors.textMuted)),
            ],
          ],
        ),
        ?actions,
      ],
    );
  }
}
