// A row of a list (DESIGN.md, List, ListItem, Section).
// Targets, semantics, keyboard (via Pressable), text scale, right-to-left (chevron mirrors).
import 'package:flutter/widgets.dart';

import '../foundation/labels.dart';
import '../foundation/pressable.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.g.dart';
import 'glyphs.dart';
import 'switch.dart';

/// A row of a list (DESIGN.md, List, ListItem, Section): a pressable row when [onPressed] is set, a plain row
/// otherwise, with an optional [leading] icon, avatar or thumbnail, a [title] and [subtitle], and [trailing] (a
/// value or a control) — a chevron by default when the row [navigates] and nothing else trails. [current] bolds
/// the title (weight 800) and marks it as the current item; [destructive] puts the title in [TsuyaColors.danger]
/// (keep it alone in the last group); [tall] grows the row for an account row.
///
/// A [Switch] without a label of its own, in [trailing] of a plain row, is named by the row: its title and subtitle
/// and the switch are one node, a toggle that toggles on a tap.
///
/// In a selectable list, [selected] shows a tick at the end: there is no Flutter role for a selected link (unlike
/// the web's `aria-pressed`, which only applies to a `<button>`), so an action row ([onPressed] set, [navigates]
/// false) announces it as a toggle; any other row announces it through an extra "selected" label instead.
class ListItem extends StatelessWidget {
  /// A row titled [title].
  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.onPressed,
    this.navigates = false,
    this.tall = false,
    this.current = false,
    this.destructive = false,
    this.selected,
    this.leading,
    this.trailing,
  });

  /// The row's title, one line (ellipsized if it must).
  final String title;

  /// Below the title, one line, muted.
  final String? subtitle;

  /// Called on a press; makes the row pressable (fill on hover, fill-strong on press). Null for a plain row.
  final VoidCallback? onPressed;

  /// Whether the row opens another screen: the default trailing chevron, when nothing else trails it.
  final bool navigates;

  /// Grows the row to [TsuyaSize.rowTall], for an account row.
  final bool tall;

  /// The current item: a bold (800) title and a marker.
  final bool current;

  /// Puts the title in [TsuyaColors.danger]; keep it alone in the last group.
  final bool destructive;

  /// In a selectable list, whether this is the chosen row: a tick at the end. Null outside a selectable list.
  final bool? selected;

  /// An icon 20, an avatar 40, or a thumbnail 40 to 48.
  final Widget? leading;

  /// A value or a control; a chevron shows by default when [navigates] and this is null.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = TsuyaTheme.of(context);
    final colors = theme.colors;
    final labels = TsuyaLabels.of(context);
    final interactive = onPressed != null;
    final ticked = selected == true;
    final chevronShown = !ticked && navigates && trailing == null;
    // a toggle state reads the selection on an action row (web: aria-pressed, only valid on a <button>); any other
    // row (a link, or a plain row) announces it through an extra label instead, read by the block below
    final toggles = interactive && !navigates;
    final announceSelected = ticked && !toggles;

    final titleStyle = theme
        .text(TsuyaType.bodyStrong)
        .copyWith(fontWeight: current ? FontWeight.w800 : null, color: destructive ? colors.danger : colors.text);
    final main = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (subtitle case final subtitle?)
          Text(
            subtitle,
            style: theme.text(TsuyaType.small).copyWith(color: colors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    Widget row(double rowWidth) {
      final parts = <Widget>[
        if (leading case final leading?)
          IconTheme.merge(
            data: IconThemeData(size: TsuyaSize.icon, color: colors.textMuted),
            child: ExcludeSemantics(child: leading),
          ),
        Expanded(child: main),
        if (trailing case final trailing?)
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rowWidth / 2),
            child: DefaultTextStyle.merge(
              style: theme
                  .text(TsuyaType.small)
                  .copyWith(color: colors.textMuted, fontFeatures: const [FontFeature.tabularFigures()]),
              child: trailing,
            ),
          )
        else if (chevronShown)
          Glyph(TsuyaGlyph.chevronRight, size: TsuyaSize.iconSm, color: colors.textMuted),
        if (ticked) Glyph(TsuyaGlyph.check, color: colors.text),
      ];
      return Row(
        children: [
          for (var i = 0; i < parts.length; i++) ...[if (i > 0) const SizedBox(width: TsuyaSpace.s12), parts[i]],
        ],
      );
    }

    Widget content = SizedBox(
      width: double.infinity,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: tall ? TsuyaSize.rowTall : TsuyaSize.row),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TsuyaSpace.s8),
          child: LayoutBuilder(builder: (context, constraints) => row(constraints.maxWidth)),
        ),
      ),
    );
    // out of flow (zero size), so it never disturbs the row's own layout: merges "Selected" into its accessible name
    if (announceSelected) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
          Semantics(label: labels.selected, child: const SizedBox.shrink()),
        ],
      );
    }

    // no ARIA-current in Flutter: a plain current row is exposed as selected, as the pressable one is
    if (!interactive) {
      final plain = Semantics(container: true, selected: current ? true : null, child: content);
      // a switch without a label of its own is named by this row: one node, the title and subtitle, toggled
      return trailing is Switch && (trailing! as Switch).label == null ? MergeSemantics(child: plain) : plain;
    }
    return Pressable(
      onPressed: onPressed,
      feedback: PressFeedback.highlight,
      selected: current ? true : null,
      toggled: toggles ? selected : null,
      child: content,
    );
  }
}
