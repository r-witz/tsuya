// A section's header (DESIGN.md, PageHeader, SectionHeader).
import 'package:flutter/widgets.dart';

import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'button.dart';

/// A section's header (DESIGN.md, SectionHeader): a [title], an optional [count], and a ghost "see all" button
/// at the end ([actionLabel], called by [onAction]); [TsuyaSpace.s32] above, [TsuyaSpace.s12] below.
class SectionHeader extends StatelessWidget {
  /// A header titled [title].
  const SectionHeader({super.key, required this.title, this.count, this.actionLabel, this.onAction});

  /// The section's title.
  final String title;

  /// Shown after the title, muted.
  final String? count;

  /// The ghost button's label at the end, such as "See all"; the button is hidden when this is null.
  final String? actionLabel;

  /// Called on a press of the ghost button; null disables it.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    return Padding(
      padding: const EdgeInsets.only(top: TsuyaSpace.s32, bottom: TsuyaSpace.s12),
      // wrapping, as the page header does: at large text on a narrow screen the count and the action go under the title
      // instead of squeezing it
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: TsuyaSpace.s8,
        children: [
          Wrap(
            spacing: TsuyaSpace.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                container: true,
                headingLevel: 2,
                child: Text(title, style: theme.text(TsuyaType.titleL).copyWith(color: colors.text)),
              ),
              if (count case final count?)
                Text(count, style: theme.text(TsuyaType.control).copyWith(color: colors.textMuted)),
            ],
          ),
          if (actionLabel case final actionLabel?)
            Button(label: actionLabel, onPressed: onAction, kind: ButtonKind.ghost, size: ButtonSize.sm),
        ],
      ),
    );
  }
}
